###
# Suppression d'une base de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Affichage de l'aide
##
if [[ -z $OLIX_MODULE_POSTGRES_BASE ]]; then
    Module.execute.usage "drop"
    critical "Nom de la base à supprimer manquante"
fi

# Si la base existe
Postgres.base.exists $OLIX_MODULE_POSTGRES_BASE
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_POSTGRES_BASE}' n'existe pas"


###
# Avertissement
##
echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base et son contenu${CVOID}"
Read.confirm "Confirmer" false
[[ $OLIX_FUNCTION_RETURN == false ]] && return


###
# Traitement
##
info "Suppression de la base '${OLIX_MODULE_POSTGRES_BASE}'"

Postgres.base.drop $OLIX_MODULE_POSTGRES_BASE
[[ $? -ne 0 ]] && critical "Echec de la suppression de la base '${OLIX_MODULE_POSTGRES_BASE}'"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_POSTGRES_BASE}${CVERT} a été supprimée avec succès${CVOID}"
