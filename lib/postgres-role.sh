###
# Gestion des rôles du serveur de bases de données PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si un rôle existe
# @param $1 : Nom du rôle
# @param $2-5 : Infos de connexion au serveur
##
function Postgres.role.exists()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.role.exists ($1, $CONNECTION)"
    Postgres.server.setPassword $5

    psql $CONNECTION postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$1'" | grep -q 1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Crée un rôle
# @param $1 : Nom du rôle
# @param $2 : Mot de passe du rôle
# @param $3 : Droits du rôle
# @param $4-7 : Infos de connexion au serveur
##
function Postgres.role.create()
{
    local CONNECTION=$(Postgres.server.connection $4 $5 $6)
    debug "Postgres.role.create ($1, $2, $3, $CONNECTION)"
    Postgres.server.setPassword $7

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        psql --echo-all $CONNECTION --command="CREATE ROLE $1 $3 ENCRYPTED PASSWORD '$2';"
    else
        psql $CONNECTION --command="CREATE ROLE $1 $3 ENCRYPTED PASSWORD '$2';" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime un rôle
# @param $1 : Nom du rôle
##
function Postgres.role.drop()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.role.drop ($1, $CONNECTION)"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        psql --echo-all $CONNECTION --command="DROP ROLE $1;"
    else
        psql $CONNECTION --command="DROP ROLE $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}
