###
# Gestion du containeur Docker de base de données PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Recupère la chaine de connexion au containeur
# @param $1 : Utilisateur postgresqlapt 
# @return string
##
function Postgres.docker.connection()
{
    local CONNECTION

    if [[ -n $1 ]]; then
        CONNECTION="$CONNECTION --username=$1"
    elif [[ -n $OLIX_MODULE_POSTGRES_USER ]]; then
        CONNECTION="$CONNECTION --username=$OLIX_MODULE_POSTGRES_USER"
    fi

    echo $CONNECTION
}


###
# Test une connexion au containeur Docker
# @param $1 : Nom du containeur
# @param $2-3 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.check()
{
    local CONNEXION=$(Postgres.docker.connection $2 $3)
    debug "Postgres.docker.check ($1, ${CONNEXION})"

    docker exec -i $1 psql $CONNEXION --command="\d" > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1

    return 0
}

