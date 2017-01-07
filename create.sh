###
# Création d'une base de données PostgreSQL
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
    Module.execute.usage "create"
    critical "Nom de la base à créer manquante"
fi
if [[ -z $OLIX_MODULE_POSTGRES_OWNER ]]; then
    Module.execute.usage "create"
    critical "Nom du propriétaire de la base manquant"
fi

# Si la base existe
Postgres.base.exists $OLIX_MODULE_POSTGRES_BASE
[[ $? -eq 0 ]] && critical "La base '${OLIX_MODULE_POSTGRES_BASE}' existe déjà"



###
# Traitement
##
info "Création de la base '${OLIX_MODULE_POSTGRES_BASE}'"

# Test si le role existe
Postgres.role.exists $OLIX_MODULE_POSTGRES_OWNER
if [[ $? -ne 0 ]]; then
    warning "Le rôle '${OLIX_MODULE_POSTGRES_OWNER}' n'existe pas"
    Read.confirm "Voulez-vous créer le rôle '${OLIX_MODULE_POSTGRES_OWNER}' ?" true
    if [[ $OLIX_FUNCTION_RETURN == false ]]; then
        warning "La base '${OLIX_MODULE_POSTGRES_BASE}' n'a pas été créée"
        return
    fi

    # Création du rôle
    Read.passwordx2 "Saisir un mot de passe pour le rôle '${OLIX_MODULE_POSTGRES_OWNER}'"
    Postgres.role.create $OLIX_MODULE_POSTGRES_OWNER $OLIX_FUNCTION_RETURN "LOGIN"
    [[ $? -ne 0 ]] && critical "Echec de la création du rôle '${OLIX_MODULE_POSTGRES_OWNER}'"
fi

# Création de la base
Postgres.base.create $OLIX_MODULE_POSTGRES_BASE $OLIX_MODULE_POSTGRES_OWNER
[[ $? -ne 0 ]] && critical "Echec de la création de la base '${OLIX_MODULE_POSTGRES_BASE}'"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_POSTGRES_BASE}${CVERT} a été créée avec succès${CVOID}"
