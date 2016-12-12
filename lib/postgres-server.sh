###
# Gestion du serveur de base de données PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si PostgreSQL est installé
# @return bool
##
function Postgres.server.installed()
{
    debug "Postgres.server.installed ()"
    getent passwd postgres > /dev/null && return 0
    return 1
}


###
# Test si PostgreSQL est en execution
# @return bool
##
function Postgres.server.running()
{
    debug "Postgres.server.running ()"
    netstat -ntpul | grep postgres > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Recupère la chaine de connexion au serveur
# @param $1 : Host du serveur PostgreSQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @return string
##
function Postgres.server.connection()
{
    local CONNECTION
    if [[ -n $1 ]]; then
        CONNECTION="$CONNECTION --host=$1"
    elif [[ -n $OLIX_MODULE_POSTGRES_HOST ]]; then
        CONNECTION="$CONNECTION --host=$OLIX_MODULE_POSTGRES_HOST"
    fi

    if [[ -n $OLIX_MODULE_POSTGRES_HOST || -n $1 ]]; then
        if [[ -n $2 ]]; then
            CONNECTION="$CONNECTION --port=$2"
        elif [[ -n $OLIX_MODULE_POSTGRES_PORT ]]; then
            CONNECTION="$CONNECTION --port=$OLIX_MODULE_POSTGRES_PORT"
        fi
    fi

    if [[ -n $3 ]]; then
        CONNECTION="$CONNECTION --username=$3"
    elif [[ -n $OLIX_MODULE_POSTGRES_USER ]]; then
        CONNECTION="$CONNECTION --username=$OLIX_MODULE_POSTGRES_USER"
    fi

    echo $CONNECTION
}


###
# Affecte le mot de passe
# @param $1 : Mot de passe
##
function Postgres.server.setPassword()
{
    if [[ -n $1 ]]; then
        export PGPASSWORD=$1
    elif [[ -n $OLIX_MODULE_POSTGRES_PASS ]]; then
        export PGPASSWORD=$OLIX_MODULE_POSTGRES_PASS
    fi
}


###
# Test une connexion au serveur de base de données
# @return bool
##
function Postgres.server.check()
{
    local CONNECTION=$(Postgres.server.connection $1 $2 $3)
    debug "Postgres.server.check (${CONNECTION})"
    Postgres.server.setPassword $4

    psql $CONNECTION --no-password --command="\d" postgres > /dev/null
    [[ $? -ne 0 ]] && return 1

    return 0
}


###
# Retroune la liste des bases de données
# @return : Liste
##
function Postgres.server.databases()
{
    local CONNECTION=$(Postgres.server.connection $1 $2 $3)
    debug "Postgres.server.databases (${CONNECTION})"
    Postgres.server.setPassword $4

    local DATABASES
    #DATABASES=$(psql --username=$DB_USER -l -t | grep -vE 'template[0|1]' | awk '{print $1}' | grep -vE 'postgres|\|')
    DATABASES=$(psql $CONNECTION --no-align --tuples-only --command="SELECT datname FROM pg_database WHERE datistemplate = 'f' AND datname <> 'postgres' AND datallowconn ORDER BY datname" 2> /dev/null)
    
    [[ $? -ne 0 ]] && return 1
    echo -n $DATABASES
    return 0
}


###
# Fait un dump des objects globaux de l'instance du serveur
# @param $1  : Fichier de dump
##
function Postgres.server.dump.objects()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.server.dump.objects (${CONNECTION})"
    Postgres.server.setPassword $5

    pg_dumpall --globals-only $CONNECTION > $1 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Fait un dump complet de l'instance du serveur
# @param $1  : Fichier de dump
##
function Postgres.server.dump.all()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.server.dump.all (${CONNECTION})"
    Postgres.server.setPassword $5

    pg_dumpall $CONNECTION > $1 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}
