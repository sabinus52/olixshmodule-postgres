###
# Gestion des bases de données PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##



###
# Vérifie si une base existe
# @param $1 : Nom de la base à vérifier
# @param $2-5 : Infos de connexion au serveur
# @return bool
##
function Postgres.base.exists()
{
    debug "Postgres.base.exists ($1)"

    local BASES=$(Postgres.server.databases $2 $3 $4 $5)
    String.list.contains "$BASES postgres" "$1" && return 0
    return 1
}


###
# Retourne le propriétaire d'une base de données
# @param $1 : Nom de la base à créer
# @param $2-5 : Infos de connexion au serveur
# @return bool
##
function Postgres.base.owner()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.base.owner ($1, ${CONNECTION})"
    Postgres.server.setPassword $5

    local OWNER=$(Postgres.action.query "SELECT pg_catalog.pg_get_userbyid(d.datdba) FROM pg_catalog.pg_database d WHERE d.datname = '$1'")
    [[ $? -ne 0 ]] && return 1
    echo -n $OWNER
    return 0
}


###
# Crée une nouvelle base de données
# @param $1 : Nom de la base à créer
# @param $2 : Nom du propriétaire de la base
# @param $3-6 : Infos de connexion au serveur
# @return bool
##
function Postgres.base.create()
{
    local CONNECTION=$(Postgres.server.connection $3 $4 $5)
    debug "Postgres.base.create ($1, $2, ${CONNECTION})"
    Postgres.server.setPassword $6

    local OWNER
    [[ -n $2 ]] && OWNER="OWNER $2"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        psql --echo-all $CONNECTION --command="CREATE DATABASE $1 $OWNER;"
    else
        psql $CONNECTION --command="CREATE DATABASE $1 $OWNER;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données
# @param $1 : Nom de la base à créer
# @param $2-5 : Infos de connexion au serveur
# @return bool
##
function Postgres.base.drop()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.base.drop ($1, ${CONNECTION})"
    Postgres.server.setPassword $5

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        psql --echo-all $CONNECTION --command="DROP DATABASE IF EXISTS $1;"
    else
        psql $CONNECTION --command="DROP DATABASE IF EXISTS $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Fait un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3  : Options en extra
# @param $4-7 : Infos de connexion au serveur
# @return bool
##
function Postgres.base.dump()
{
    local CONNECTION=$(Postgres.server.connection $4 $5 $6)
    debug "Postgres.base.dump ($1, $2, $3, ${CONNECTION})"
    Postgres.server.setPassword $7

    debug "pg_dump $3 $CONNECTION --file=$2 $1"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        pg_dump --verbose $3 $CONNECTION --file=$2 $1
    else
        pg_dump $3 $CONNECTION --file=$2 $1 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Restaure un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3-6 : Infos de connexion au serveur
# @return bool
##
function Postgres.base.restore()
{
    local CONNECTION=$(Postgres.server.connection $3 $4 $5)
    debug "Postgres.base.restore ($1, $2, ${CONNECTION})"
    Postgres.server.setPassword $6

    debug "pg_restore $CONNECTION --dbname=$1 $2"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        pg_restore --verbose $CONNECTION --dbname=$1 $2
    else
        pg_restore $CONNECTION --dbname=$1 $2 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Fait une sauvegarde d'une base PostgreSQL
# @param $1 : Nom de la base
# @param $2 : Format des dumps
# @param $3 : Format du dump
# @param $4 : Compression
# @return bool
##
function Postgres.base.backup()
{
    local CONNECTION=$(Postgres.server.connection $5 $6 $7)
    debug "Postgres.base.backup ($1, $2, $3, $4, $CONNECTION)"

    local BINCOMPRESS=$(Compression.binary $4)

    Postgres.base.dump $1 $2 $3 $5 $6 $7

    return $?
}


###
# Retourne l'extension d'un dump en fonction du format du dump
# @param $1 : Format du dump
##
function Postgres.base.dump.ext()
{
    debug "Postgres.base.dump.ext ($1)"
    local FORMAT=$(echo "$1" | grep -oP "\--format=\K\w+")
    FORMAT=${FORMAT:0:1}
    case $FORMAT in
        c)      echo "dumpz";;
        p)      echo "sql";;
        *)      echo "dump";;
    esac
}


###
# Réinitialiase complètement une base
# @param $1 : Nom de la base
# @param $2 : Nom du rôle
# @param $3 : Mot de passe du rôle
##
function Postgres.base.initialize()
{
    debug "Postgres.base.initialize ($1, $2, $3)"

    Postgres.base.drop $1 $4 $5 $6 $7 || return 1
    if Postgres.role.exists $2 $4 $5 $6 $7; then
        Postgres.role.drop $2 $4 $5 $6 $7 || return 1
    fi
    Postgres.role.create $2 $3 $4 $5 $6 $7 || return 1
    Postgres.base.create $1 $2 $4 $5 $6 $7 || return 1
    return 0
}
