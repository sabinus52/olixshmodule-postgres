###
# Librairies des actions du module PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Execute une requete
# @apram $1 : Requete
# @param $2-5 : Infos de connexion au serveur
##
function Postgres.action.execSQL()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.action.execSQL ($1, ${CONNECTION})"
    Postgres.server.setPassword $5

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        psql $CONNECTION --command="$1"
    else
        psql $CONNECTION --command="$1" > /dev/null 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    return $?
}


###
# Execute une requete et retourne la valeur d'un champ
# @apram $1 : Requete
# @param $2-5 : Infos de connexion au serveur
# @return : un tuple
##
function Postgres.action.query()
{
    local CONNECTION=$(Postgres.server.connection $2 $3 $4)
    debug "Postgres.action.query ($1, ${CONNECTION})"
    Postgres.server.setPassword $5

    echo $(psql $CONNECTION --tuples-only --no-align --command="$1" 2> ${OLIX_LOGGER_FILE_ERR})
    return $?
}


###
# Copie une base de données depuis un serveur distant vers une base locale
# @param $1  : Chaine de connexion de la source
# @param $2  : Mot de passe de la source
# @param $3  : Base source
# @param $4  : Base de destination
# @return bool
##
function Postgres.action.synchronize()
{
    debug "Postgres.action.synchronize ($1, $2, $3, $4)"
    local CONNECTION=$(Postgres.server.connection)
    Postgres.server.setPassword $2

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        pg_dump --verbose --format=c $1 $3 | pg_restore --verbose $CONNECTION --dbname=$4
    else
        pg_dump --format=c $1 $3 | pg_restore $CONNECTION --dbname=$4 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -eq 0 && $PIPESTATUS -eq 0 ]] && return 0
    return 1
}


###
# Fait une sauvegarde à chaud de l'instance
# @param $1 : Chemin de l'instance
# @param $2 : Nom du fichier de sortie
# @param $3 : Format de compression
##
function Postgres.action.backup.pitr()
{
    local CONNECTION=$(Postgres.server.connection $4 $5 $6)
    debug "Postgres.action.backup.pitr ($1, $2, $3, ${CONNECTION})"
    Postgres.server.setPassword $7

    local COMPRESS
    case $(String.lower $3) in
        bz|bz2) COMPRESS="--bzip2";;
        gz)     COMPRESS="--gzip";;
    esac

    local ERROR=0

    info "Signalisation à Postgres du début de la sauvegarde"
    Postgres.action.execSQL "SELECT pg_start_backup('archivelog');" || ERROR=1

    info "Création de l'archive -> $2"
    Compression.tar.create "$1" "$2" "" "--ignore-failed-read $COMPRESS" || ERROR=1

    info "Signalisation à Postgres de la fin de la sauvegarde"
    Postgres.action.execSQL "SELECT pg_stop_backup();" || ERROR=1

    return $ERROR
}


###
# Purge les archives WALS
# @param $1 : Emplacement des archives WALS
# @param $2 : Retention
# @return bool
##
function Postgres.action.wals.purge()
{
    debug "Postgres.action.wals.purge ($1, $2)"
    local PURGE RET
    local LIST_FILE_PURGED=$(System.file.temp)

    # Détermine la retention
    case $2 in
        log)    PURGE=5;;
        *)      PURGE=$2;;
    esac

    Filesystem.purge.standard "$1" "" "$PURGE" "$LIST_FILE_PURGED"
    RET=$?
    debug "$(cat ${LIST_FILE_PURGED})"
    return $RET
}
