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
# Test une connexion au serveur de base de données
# @param $1  : Host du serveur Postgres
# @param $2  : Port du serveur
# @param $4  : Utilisateur mysql
# @param $4  : Mot de passe
# @return bool
##
function module_postgres_checkConnect()
{
    local OPTS=$(module_postgres_getOptionsConnection "$1" "$2" "$3")
    logger_debug "module_postgres_checkConnect (${OPTS})"
    module_postgres_setPassword "$4"

    psql ${OPTS} --no-password --command="\d" postgres > /dev/null
    [[ $? -ne 0 ]] && return 1

    return 0
}


###
# Execute une requete
# @apram $1 : Requete
# @param $2 : Host du serveur Postgres
# @param $3 : Port du serveur
# @param $4 : Utilisateur postgres
# @param $5  : Mot de passe
# @return : Liste
##
function module_postgres_execSQL()
{
    local OPTS=$(module_postgres_getOptionsConnection "$2" "$3" "$4")
    logger_debug "module_postgres_execSQL (${OPTS})"
    module_postgres_setPassword "$5"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        psql ${OPTS} --command="$1" 2> ${OLIX_LOGGER_FILE_ERR}
    else
        psql ${OPTS} --command="$1" > /dev/null 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Execute une requete et retourne la valeur d'un champ
# @apram $1 : Requete
# @param $2 : Host du serveur Postgres
# @param $3 : Port du serveur
# @param $4 : Utilisateur postgres
# @param $5 : Mot de passe
# @return : un champ
##
function module_postgres_getSingleResultSQL()
{
    local OPTS=$(module_postgres_getOptionsConnection "$2" "$3" "$4")
    logger_debug "module_postgres_getSingleResultSQL (${OPTS})"
    module_postgres_setPassword "$5"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        echo $(psql ${OPTS} --tuples-only --no-align --command="$1" 2> ${OLIX_LOGGER_FILE_ERR})
    else
        echo $(psql ${OPTS} --tuples-only --no-align --command="$1" > /dev/null 2> ${OLIX_LOGGER_FILE_ERR})
    fi
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
    local OPTS=$(module_postgres_getOptionsConnection "$1" "$2" "$3")
    logger_debug "module_postgres_getListDatabases (${OPTS})"
    module_postgres_setPassword "$4"

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
# @return string
##
function module_postgres_getOptionsConnection()
{
    logger_debug "module_postgres_getOptionsConnection($1, $2, $3)"
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
# Affecte le password pour la chaine de connexion
# @param $1 : Mot de passe
##
function module_postgres_setPassword()
{
    logger_debug "module_postgres_setPassword ($1)"

    if [[ -n $1 ]]; then
        export PGPASSWORD=$1
    elif [[ -n ${OLIX_MODULE_POSTGRES_PASS} ]]; then
        export PGPASSWORD=${OLIX_MODULE_POSTGRES_PASS}
    fi
}


###
# Crée une nouvelle base de données
# @param $1 : Nom de la base à créer
# @param $2 : Propriétaire
# @param $3 : Host du serveur Postgres
# @param $4 : Port du serveur
# @param $5 : Utilisateur postgres
# @param $6 : Mot de passe
# @return bool
##
function module_postgres_createDatabase()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_createDatabase ($1, ${OPTS})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        psql --echo-all ${OPTS} --command="CREATE DATABASE $1 OWNER $2;"
    else
        psql ${OPTS} --command="CREATE DATABASE $1 OWNER $2;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données
# @param $1 : Nom de la base à créer
# @param $2 : Host du serveur Postgres
# @param $3 : Port du serveur
# @param $4 : Utilisateur postgres
# @param $5 : Mot de passe
# @return bool
##
function module_postgres_dropDatabase()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_dropDatabase ($1, ${OPTS})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        psql --echo-all ${OPTS} --command="DROP DATABASE $1;"
    else
        psql ${OPTS} --command="DROP DATABASE $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données même si elle n'existe pas
# @param $1 : Nom de la base à créer
# @param $2 : Host du serveur Postgres
# @param $3 : Port du serveur
# @param $4 : Utilisateur postgres
# @param $5 : Mot de passe
# @return bool
##
function module_postgres_dropDatabaseIfExists()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_dropDatabaseIfExists ($1, ${OPTS})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        psql --echo-all ${OPTS} --command="DROP DATABASE IF EXISTS $1;"
    else
        psql ${OPTS} --command="DROP DATABASE IF EXISTS $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Crée un rôle
# @param $1 : Nom du rôle
# @param $2 : Mot de passe du rôle
# @param $3 : Droits du rôle
# @param $4 : Host du serveur MySQL
# @param $5 : Port du serveur
# @param $6 : Utilisateur mysql
# @param $7 : Mot de passe
##
function module_postgres_createRole()
{
    local OPTS=$(module_postgres_getOptionsConnection "$4" "$5" "$6")
    logger_debug "module_postgres_createRole ($1, $2, $3, ${OPTS})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        psql --echo-all ${OPTS} --command="CREATE ROLE $1 $3 ENCRYPTED PASSWORD '$2';"
    else
        psql ${OPTS} --command="CREATE ROLE $1 $3 ENCRYPTED PASSWORD '$2';" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime un rôle
# @param $1 : Nom du rôle
# @param $2 : Host du serveur MySQL
# @param $3 : Port du serveur
# @param $4 : Utilisateur mysql
# @param $5 : Mot de passe
##
function module_postgres_dropRole()
{
    local OPTS=$(module_postgres_getOptionsConnection "$2" "$3" "$4")
    logger_debug "module_postgres_dropRole ($1, ${OPTS})"

    # Test si le role existe
    psql ${OPTS} postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$1'" | grep -q 1
    if [[ $? -ne 0 ]]; then
        logger_warning "Le rôle '$1' n'existe pas"
        return 0
    fi

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        psql --echo-all ${OPTS} --command="DROP ROLE $1;"
    else
        psql ${OPTS} --command="DROP ROLE $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Fait un dump des objects globaux de l'instance du serveur
# @param $1  : Fichier de dump
# @param $2  : Host du serveur Postgres
# @param $3  : Port du serveur
# @param $4  : Utilisateur Postgres
# @param $5  : Mot de passe
# @return bool
##
function module_postgres_dumpOnlyGlobalObjects()
{
    local OPTS=$(module_postgres_getOptionsConnection "$2" "$3" "$4")
    logger_debug "module_postgres_dumpOnlyGlobalObjects ($1, ${OPTS})"
    module_postgres_setPassword "$5"

    pg_dumpall --globals-only ${OPTS} > $1 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Fait un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3  : Host du serveur Postgres
# @param $4  : Port du serveur
# @param $5  : Utilisateur Postgres
# @param $6  : Mot de passe
# @return bool
##
function module_postgres_dumpDatabase()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_dumpDatabase ($1, $2, ${OPTS})"
    module_postgres_setPassword "$6"

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
# @param $6  : Mot de passe
# @return bool
##
function module_postgres_restoreDatabase()
{
    local OPTS=$(module_postgres_getOptionsConnection "$3" "$4" "$5")
    logger_debug "module_postgres_restoreDatabase ($1, $2, ${OPTS})"
    module_postgres_setPassword "$6"

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
# @param $1  : Host du serveur Postgres distant
# @param $2  : Port du serveur distant
# @param $3  : Utilisateur Postgres distant
# @param $4  : Mot de passe distant
# @param $5  : Base source distante
# @param $6  : Base de destination locale
# @return bool
##
function module_postgres_synchronizeDatabase()
{
    local OPTS_LOCAL=$(module_postgres_getOptionsConnection "" "" "")
    logger_debug "module_postgres_synchronizeDatabase ($1, $2, $3, $4, $5, $6, ${OPTS_LOCAL})"
    module_postgres_setPassword "$4"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        pg_dump --verbose --format=c --host=$1 --port=$2 --username=$3 $5 | pg_restore --verbose ${OPTS_LOCAL} --dbname=$5
    else
        pg_dump --format=c --host=$1 --port=$2 --username=$3 $5 | pg_restore ${OPTS_LOCAL} --dbname=$5 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -eq 0 && ${PIPESTATUS} -eq 0 ]] && return 0
    return 1
}


###
# Fait une sauvegarde d'une base Postgres
# @param $1 : Nom de la base
# @param $2 : Emplacement du backup
# @param $3 : Compression
# @param $4 : Rétention pour la purge
# @param $5 : FTP type utilisé (false|lftp|ncftp)
# @param $6 : Host du FTP
# @param $7 : Utilisateur du FTP
# @param $8 : Password du FTP
# @param $9 : Chemin du FTP
# @return bool
##
function module_postgres_backupDatabase()
{
    logger_debug "module_postgres_backupDatabase ($1)"
    local BASE=$1
    local DIRBCK=$2
    local COMPRESS=$3
    local PURGE=$4
    local FTP=$5
    local FTP_HOST=$6
    local FTP_USER=$7
    local FTP_PASS=$8
    local FTP_PATH=$9

    stdout_printHead2 "Dump de la base Postgres %s" "${BASE}"

    if ! module_postgres_isBaseExists "${BASE}"; then
        logger_warning "La base '${BASE}' n'existe pas"
        return 1
    fi

    local DUMP="${DIRBCK}/dump-${BASE}-${OLIX_SYSTEM_DATE}.dump"
    logger_info "Sauvegarde basePostgres (${BASE}) -> ${DUMP}"

    local START=${SECONDS}

    module_postgres_dumpDatabase "${BASE}" "${DUMP}"
    stdout_printMessageReturn $? "Sauvegarde de la base" "$(filesystem_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_error && return 1

    backup_finalize "${DUMP}" "${DIRBCK}" "${COMPRESS}" "${PURGE}" "dump-${BASE}-*" \
        "${FTP}" "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_PATH}"

    return $?
}
