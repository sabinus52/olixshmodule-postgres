###
# Synchronisation d'une base de données depuis un serveur PostgreSQL distant
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Vérification des paramètres
##
if [[ -z $OLIX_MODULE_POSTGRES_SOURCE_HOST ]]; then
    Module.execute.usage "sync"
    critical "Nom du serveur distant manquant"
fi
if [[ -z $OLIX_MODULE_POSTGRES_SOURCE_BASE ]]; then
    Module.execute.usage "sync"
    critical "Nom de la base source manquante"
fi
if [[ -z $OLIX_MODULE_POSTGRES_BASE ]]; then
    Module.execute.usage "sync"
    critical "Nom de la base destination manquante"
fi


###
# Récupération des infos de connexion de la source
##
OLIX_MODULE_POSTGRES_SOURCE_USER=$(String.connection.user $OLIX_MODULE_POSTGRES_SOURCE_HOST)
[[ -z $OLIX_MODULE_POSTGRES_SOURCE_USER ]] && OLIX_MODULE_POSTGRES_SOURCE_USER="postgres"
OLIX_MODULE_POSTGRES_SOURCE_PORT=$(String.connection.port $OLIX_MODULE_POSTGRES_SOURCE_HOST)
[[ -z $OLIX_MODULE_POSTGRES_SOURCE_PORT ]] && OLIX_MODULE_POSTGRES_SOURCE_PORT="5432"
OLIX_MODULE_POSTGRES_SOURCE_HOST=$(String.connection.host $OLIX_MODULE_POSTGRES_SOURCE_HOST)
Read.password "Mot de passe de connexion au serveur PostgreSQL (${OLIX_MODULE_POSTGRES_SOURCE_HOST}) en tant que ${OLIX_MODULE_POSTGRES_SOURCE_USER}"
OLIX_MODULE_POSTGRES_SOURCE_PASS=$OLIX_FUNCTION_RETURN


###
# Vérification du serveur source
## 
Postgres.server.check "$OLIX_MODULE_POSTGRES_SOURCE_HOST" "$OLIX_MODULE_POSTGRES_SOURCE_PORT" "$OLIX_MODULE_POSTGRES_SOURCE_USER" "$OLIX_MODULE_POSTGRES_SOURCE_PASS"
[[ $? -ne 0 ]] && critical "Echec de connexion au serveur PostgreSQL source ${OLIX_MODULE_POSTGRES_SOURCE_USER}@${OLIX_MODULE_POSTGRES_SOURCE_HOST}:${OLIX_MODULE_POSTGRES_SOURCE_PORT}"
Postgres.base.exists $OLIX_MODULE_POSTGRES_SOURCE_BASE $OLIX_MODULE_POSTGRES_SOURCE_HOST $OLIX_MODULE_POSTGRES_SOURCE_PORT $OLIX_MODULE_POSTGRES_SOURCE_USER $OLIX_MODULE_POSTGRES_SOURCE_PASS
[[ $? -ne 0 ]] && critical "La base source '${OLIX_MODULE_POSTGRES_SOURCE_BASE}' n'existe pas"


###
# Si la base destination existe -> suppression
##
if Postgres.base.exists $OLIX_MODULE_POSTGRES_BASE; then
    # Avertissement
    echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base ${CCYAN}${OLIX_MODULE_POSTGRES_BASE}${CJAUNE} et son contenu${CVOID}"
    Read.confirm "Confirmer" false
    [[ $OLIX_FUNCTION_RETURN == false ]] && return

    # Recupération du propriétaire de la base
    OLIX_MODULE_POSTGRES_OWNER=$(Postgres.base.owner $OLIX_MODULE_POSTGRES_BASE)
    [[ -z $OLIX_MODULE_POSTGRES_OWNER ]] && critical "Impossible de récupérer le propriétaire de la base '${OLIX_MODULE_POSTGRES_BASE}'"

    # Suppression de la base
    Postgres.base.drop $OLIX_MODULE_POSTGRES_BASE
    [[ $? -ne 0 ]] && critical "Echec de la suppression de la base '${OLIX_MODULE_POSTGRES_BASE}'"
fi


###
# Traitement
##
info "Synchronisation de la base '${OLIX_MODULE_POSTGRES_SOURCE_BASE}' (${OLIX_MODULE_POSTGRES_SOURCE_USER}@${OLIX_MODULE_POSTGRES_SOURCE_HOST}:${OLIX_MODULE_POSTGRES_SOURCE_PORT}) vers la base '${OLIX_MODULE_POSTGRES_BASE}'"

# Création de la nouvelle base
Postgres.base.create $OLIX_MODULE_POSTGRES_BASE $OLIX_MODULE_POSTGRES_OWNER
[[ $? -ne 0 ]] && critical "Echec de la création de la base '${OLIX_MODULE_POSTGRES_BASE}'"

# Synchronisation
Postgres.action.synchronize \
    "--host=$OLIX_MODULE_POSTGRES_SOURCE_HOST --port=$OLIX_MODULE_POSTGRES_SOURCE_PORT --user=$OLIX_MODULE_POSTGRES_SOURCE_USER" "$OLIX_MODULE_POSTGRES_SOURCE_PASS" \
    "$OLIX_MODULE_POSTGRES_SOURCE_BASE" "$OLIX_MODULE_POSTGRES_BASE"
[[ $? -ne 0 ]] && critical "Echec de la synchronisation de '${OLIX_MODULE_POSTGRES_BASE}' depuis '${OLIX_MODULE_POSTGRES_SOURCE_BASE}' (${OLIX_MODULE_POSTGRES_SOURCE_USER}@${OLIX_MODULE_POSTGRES_SOURCE_HOST}:${OLIX_MODULE_POSTGRES_SOURCE_PORT})"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_POSTGRES_BASE}${CVERT} a été synchronisée avec succès depuis la base ${CCYAN}${OLIX_MODULE_POSTGRES_SOURCE_BASE} (${OLIX_MODULE_POSTGRES_SOURCE_USER}@${OLIX_MODULE_POSTGRES_SOURCE_HOST}:${OLIX_MODULE_POSTGRES_SOURCE_PORT})${CVOID}"
