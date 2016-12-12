###
# Restauration d'un dump d'une base de données PostgreSQL
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
if [[ -z $OLIX_MODULE_POSTGRES_DUMP ]]; then
    Module.execute.usage "restore"
    critical "Nom du fichier dump manquant"
fi
if [[ -z $OLIX_MODULE_POSTGRES_BASE ]]; then
    Module.execute.usage "restore"
    critical "Nom de la base à restaurer manquante"
fi

# Si le dump existe
File.exists $OLIX_MODULE_POSTGRES_DUMP
[[ $? -ne 0 ]] && critical "Le dump '${OLIX_MODULE_POSTGRES_DUMP}' est absent ou inaccessible"

# Si la base existe
Postgres.base.exists $OLIX_MODULE_POSTGRES_BASE
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_POSTGRES_BASE}' n'existe pas"


###
# Avertissement
##
echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base '${OLIX_MODULE_POSTGRES_BASE}' et son contenu${CVOID}"
Read.confirm "Confirmer" false
[[ $OLIX_FUNCTION_RETURN == false ]] && return


###
# Traitement
##
info "Restauration du dump '${OLIX_MODULE_POSTGRES_DUMP}' vers la base '${OLIX_MODULE_POSTGRES_BASE}'"

# Recupération du propriétaire de la base
OLIX_MODULE_POSTGRES_OWNER=$(Postgres.base.owner $OLIX_MODULE_POSTGRES_BASE)
[[ -z $OLIX_MODULE_POSTGRES_OWNER ]] && critical "Impossible de récupérer le propriétaire de la base '${OLIX_MODULE_POSTGRES_BASE}'"

#Suppression et création de la base
info "Suppression et création de la base '${OLIX_MODULE_POSTGRES_BASE}' comme propriétaire '${OLIX_MODULE_POSTGRES_OWNER}'"
Postgres.base.drop $OLIX_MODULE_POSTGRES_BASE
[[ $? -ne 0 ]] && critical "Impossible de supprimer la base '${OLIX_MODULE_POSTGRES_BASE}'"
Postgres.base.create $OLIX_MODULE_POSTGRES_BASE $OLIX_MODULE_POSTGRES_OWNER
[[ $? -ne 0 ]] && critical "Impossible de créer la base '${OLIX_MODULE_POSTGRES_BASE}'"

# Restauration
Postgres.base.restore $OLIX_MODULE_POSTGRES_BASE $OLIX_MODULE_POSTGRES_DUMP
[[ $? -ne 0 ]] && critical "Echec de la restauration du dump '${OLIX_MODULE_POSTGRES_DUMP}' vers la base '${OLIX_MODULE_POSTGRES_BASE}'"



###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_POSTGRES_BASE}${CVERT} a été restaurée avec succès depuis ${CCYAN}${OLIX_MODULE_POSTGRES_DUMP}${CVOID}"
