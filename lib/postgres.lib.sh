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
# Vérifie si une base existe
# @param $1 : Nom de la base à vérifier
# @param $2 : Host du serveur Postgres
# @param $3 : Port du serveur
# @param $4 : Utilisateur postgres
# @return bool
##
function module_postgres_isBaseExists()
{
    logger_debug "module_postgres_isBaseExists ($1, $2, $3, $4)"

    local BASES=$(module_postgres_getListDatabases "$2" "$3" "$4")
    core_contains "$1" "${BASES}" && return 0
    return 1
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
    local OPTS=$(module_postgres_getOptionsConnection "$1" "$2" "$3" "$4")
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


###
# Fait un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3  : Host du serveur Postgres
# @param $4  : Port du serveur
# @param $5  : Utilisateur Postgres
# @return bool
##
function module_postgres_dumpDatabase()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_dumpDatabase ($1, $2, ${OPTS})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        pg_dump --verbose --format=c ${OPTS} --file=$2 $1
    else
        pg_dump --format=c ${OPTS} --file=$2 $1 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Restaure un dump d'une base
# @param $1  : Fichier de dump
# @param $2  : Nom de la base
# @param $3  : Host du serveur Postgres
# @param $4  : Port du serveur
# @param $5  : Utilisateur Postgres
# @return bool
##
function module_postgres_restoreDatabase()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_restoreDatabase ($1, $2, ${OPTS})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        pg_restore --verbose ${OPTS} --dbname=$2 $1
    else
        pg_restore ${OPTS} --dbname=$2 $1 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Copie une base de données depuis un serveur distant vers une base locale
# @param $1  : Paramètre de connexion de la source
# @param $2  : Base source
# @param $3  : Paramètre de connexion locale
# @param $4  : Base de destination
# @return bool
##
function module_postgres_synchronizeDatabase()
{
    logger_debug "module_postgres_synchronizeDatabase ($1, $2, $3, $4)"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        pg_dump --verbose --format=c $1 $2 | pg_restore --verbose $3 --dbname=$4
    else
        pg_dump --format=c $1 $2 | pg_restore $3 --dbname=$4 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -eq 0 && ${PIPESTATUS} -eq 0 ]] && return 0
    return 1
}
