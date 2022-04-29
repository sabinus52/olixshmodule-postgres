###
# Gestion du containeur Docker de base de données PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Recupère la chaine de connexion au containeur
# @param $1 : Utilisateur postgresql
# @return string
##
function Postgres.docker.connection()
{
    local CONNECTION
    debug "Postgres.docker.connection ($1, $OLIX_MODULE_POSTGRES_USER)"

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
# @param $2 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.check()
{
    local CONNEXION=$(Postgres.docker.connection $2)
    debug "Postgres.docker.check ($1, ${CONNEXION})"

    docker exec -i $1 psql $CONNEXION --command="\d" > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1

    return 0
}



###
# Retroune la liste des bases de données
# @param $1 : Nom du containeur
# @param $2 : Infos de connexion au serveur
# @return : Liste
##
function Postgres.docker.databases()
{
    local CONNEXION=$(Postgres.docker.connection $2)
    debug "Postgres.docker.databases ($1, ${CONNEXION})"

    local DATABASES
    DATABASES=$(docker exec -i $1 psql $CONNEXION --no-align --tuples-only --command="SELECT datname FROM pg_database WHERE datistemplate = 'f' AND datname <> 'postgres' AND datallowconn ORDER BY datname")
    [[ $? -ne 0 ]] && return 1
    echo -n $DATABASES
    return 0
}


###
# Vérifie si une base existe
# @param $1 : Nom du containeur
# @param $2 : Nom de la base à vérifier
# @param $3 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.base.exists()
{
    debug "Postgres.docker.base.exists ($1, $2)"

    local BASES=$(Postgres.docker.databases $1 $3)
    String.list.contains "$BASES postgres" "$2" && return 0
    return 1
}


###
# Fait un dump d'une base
# @param $1 : Nom du containeur
# @param $2 : Nom de la base
# @param $3 : Fichier de dump
# @param $4 : Format du dump
# @param $5 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.base.dump()
{
    local CONNECTION=$(Postgres.docker.connection $5)
    debug "Postgres.docker.base.dump ($1, $2, $3, $4, ${CONNECTION})"

    local FORMAT=c
    [[ -n $4 ]] && FORMAT=$4
    FORMAT=${FORMAT:0:1}

    debug "docker exec -i $1 pg_dump --format=$FORMAT $CONNECTION $2 > $3"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        docker exec -i $1 pg_dump --verbose --format=$FORMAT $CONNECTION $2 > $3
    else
        docker exec -i $1 pg_dump --format=$FORMAT $CONNECTION $2 > $3 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Restaure une restauration d'une base
# @param $1 : Nom du containeur
# @param $2 : Nom de la base
# @param $3 : Fichier de dump
# @param $4 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.base.restore()
{
    local CONNECTION=$(Postgres.docker.connection $4)
    debug "Postgres.docker.base.restore ($1, $2, $3, ${CONNECTION})"

    debug "docker exec -i $1 pg_restore $CONNECTION --dbname=$2 < $3"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        docker exec -i $1 pg_restore --verbose $CONNECTION --dbname=$2 < $3
    else
        docker exec -i $1 pg_restore $CONNECTION --dbname=$2 < $3 2> ${OLIX_LOGGER_FILE_ERR}
    fi

    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Crée une nouvelle base de données
# @param $1 : Nom du containeur
# @param $2 : Nom de la base à créer
# @param $3 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.base.create()
{
    local CONNECTION=$(Postgres.docker.connection $3)
    debug "Postgres.docker.base.create ($1, $2, ${CONNECTION})"

    docker exec -i $1 createdb ${CONNECTION} $2 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données
# @param $1 : Nom du containeur
# @param $2 : Nom de la base à créer
# @param $3 : Infos de connexion au serveur
# @return bool
##
function Postgres.docker.base.drop()
{
    local CONNECTION=$(Postgres.docker.connection $3)
    debug "Postgres.docker.base.drop ($1, $2, ${CONNECTION})"

    docker exec -i $1 dropdb --if-exists ${CONNECTION} $2 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}
