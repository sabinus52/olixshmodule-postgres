###
# Gestion du serveur de base de données PostreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si PostreSQL est installé
# @return bool
##
function module_postgres_isInstalled()
{
    logger_debug "module_postgres_isInstalled ()"
    getent passwd postgres > /dev/null
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Test si PostreSQL est en execution
# @return bool
##
function module_postgres_isRunning()
{
    logger_debug "module_postgres_isRunning ()"
    netstat -ntpul | grep postgres > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Retroune la liste des bases de données
# @param $1 : Host du serveur Postgres
# @param $2 : Port du serveur
# @param $3 : Utilisateur postgres
# @param $4 : Mot de passe
# @return : Liste
##
function module_postgres_getListDatabases()
{
    local OPTS=$(module_postgres_getOptionsConnection $1 $2 $3 $4)
    logger_debug "module_postgres_getListDatabases (${OPTS})"

    local DATABASES
    #DATABASES=$(psql --username=$DB_USER -l -t | grep -vE 'template[0|1]' | awk '{print $1}' | grep -vE 'postgres|\|')
    DATABASES=$(psql ${OPTS} --no-align --tuples-only --command="SELECT datname FROM pg_database WHERE datistemplate = 'f' AND datallowconn ORDER BY datname" 2> /dev/null)
    [[ $? -ne 0 ]] && return 1
    echo -n ${DATABASES}
    return 0
}


###
# Recupère la chaine de connexion au serveur
# @param $1 : Host du serveur Postgres
# @param $2 : Port du serveur
# @param $3 : Utilisateur postgres
# @param $4 : Mot de passe
# @return string
##
function module_postgres_getOptionsConnection()
{
    local OPTIONS

    if [[ -n $1 ]]; then
        OPTIONS="${OPTIONS} --host=$1"
    elif [[ -n ${OLIX_MODULE_POSTGRES_HOST} ]]; then
        OPTIONS="${OPTIONS} --host=${OLIX_MODULE_POSTGRES_HOST}"
    fi

    if [[ -n $2 ]]; then
        OPTIONS="${OPTIONS} --port=$2"
    elif [[ -n ${OLIX_MODULE_POSTGRES_PORT} ]]; then
        OPTIONS="${OPTIONS} --port=${OLIX_MODULE_POSTGRES_PORT}"
    fi

    if [[ -n $3 ]]; then
        OPTIONS="${OPTIONS} --username=$3"
    elif [[ -n ${OLIX_MODULE_POSTGRES_USER} ]]; then
        OPTIONS="${OPTIONS} --username=${OLIX_MODULE_POSTGRES_USER}"
    fi

    echo ${OPTIONS}
}
