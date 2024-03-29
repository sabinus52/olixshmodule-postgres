###
# Réalisation d'un dump d'une base de données PostgreSQL
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
if [[ -z $OLIX_MODULE_POSTGRES_BASE ]]; then
    Module.execute.usage "dump"
    critical "Nom de la base à dumper manquante"
fi
if [[ -z $OLIX_MODULE_POSTGRES_DUMP ]]; then
    Module.execute.usage "dump"
    critical "Nom du fichier dump manquant"
fi

# Si la base existe
if [[ -z ${OLIX_MODULE_POSTGRES_DOCK} ]]; then
    Postgres.base.exists $OLIX_MODULE_POSTGRES_BASE
else
    Postgres.docker.base.exists "${OLIX_MODULE_POSTGRES_DOCK}" "$OLIX_MODULE_POSTGRES_BASE"
fi
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_POSTGRES_BASE}' n'existe pas"

# Si le dump peut être créé
File.created $OLIX_MODULE_POSTGRES_DUMP
[[ $? -ne 0 ]] && critical "Impossible de créer le fichier '${OLIX_MODULE_POSTGRES_DUMP}'"


###
# Traitement
##
info "Dump de la base '${OLIX_MODULE_POSTGRES_BASE}' vers le fichier '${OLIX_MODULE_POSTGRES_DUMP}'"

if [[ -z ${OLIX_MODULE_POSTGRES_DOCK} ]]; then

    # Mode server
    Postgres.base.dump $OLIX_MODULE_POSTGRES_BASE $OLIX_MODULE_POSTGRES_DUMP "--format=$OLIX_MODULE_POSTGRES_FORMAT $OLIX_MODULE_POSTGRES_EXTRAOPTS"
    [[ $? -ne 0 ]] && critical "Echec du dump de la base '${OLIX_MODULE_POSTGRES_BASE}' vers le fichier '${OLIX_MODULE_POSTGRES_DUMP}'"

else

    # Mode docker
    Postgres.docker.base.dump ${OLIX_MODULE_POSTGRES_DOCK} ${OLIX_MODULE_POSTGRES_BASE} ${OLIX_MODULE_POSTGRES_DUMP} "--format=${OLIX_MODULE_POSTGRES_FORMAT} $OLIX_MODULE_POSTGRES_EXTRAOPTS"
    [[ $? -ne 0 ]] && critical "Echec du dump de la base ${OLIX_MODULE_POSTGRES_DOCK}:'${OLIX_MODULE_POSTGRES_BASE}' vers le fichier '${OLIX_MODULE_POSTGRES_DUMP}'"

fi


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_POSTGRES_BASE}${CVERT} a été sauvegardée avec succès dans ${CCYAN}${OLIX_MODULE_POSTGRES_DUMP}${CVOID}"
