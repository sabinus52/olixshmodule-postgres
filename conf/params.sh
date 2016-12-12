###
# Parse les paramètres de la commande en fonction des options
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##



###
# Parsing des paramètres
##
function olixmodule_postgres_params_parse()
{
    debug "olixmodule_postgres_params_parse ($@)"
    local ACTION=$1
    local PARAM

    shift
    while [[ $# -ge 1 ]]; do
        case $1 in
            --host=*)
                OLIX_MODULE_POSTGRES_HOST=$(String.explode.value $1)
                ;;
            --port=*)
                OLIX_MODULE_POSTGRES_PORT=$(String.explode.value $1)
                ;;
            --user=*)
                OLIX_MODULE_POSTGRES_USER=$(String.explode.value $1)
                ;;
            --pass=*)
                OLIX_MODULE_POSTGRES_PASS=$(String.explode.value $1)
                ;;
            --format=*)
                PARAM=$(String.explode.value $1)
                PARAM=$(String.lower ${PARAM})
                String.list.contains "c custom d directory t tar p plain" "${PARAM}"
                [[ $? -eq 0 ]] && OLIX_MODULE_POSTGRES_FORMAT=${PARAM} || warning "Format de fichier de sortie inconnu, utilisation de celui par défaut"
                ;;
            --pgdata=*)
                OLIX_MODULE_POSTGRES_PATH=$(String.explode.value $1)
                ;;
            --wals=*)
                OLIX_MODULE_POSTGRES_WALS=$(String.explode.value $1)
                ;;
            --dir=*)
                OLIX_MODULE_POSTGRES_BACKUP_DIR=$(String.explode.value $1)
                ;;
            --purge=*)
                OLIX_MODULE_POSTGRES_BACKUP_PURGE=$(String.explode.value $1)
                ;;
            --gz|--bz2)
                OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${1/--/}
                ;;
            --html)
                OLIX_MODULE_POSTGRES_BACKUP_REPORT="HTML"
                ;;
            --email=*)
                OLIX_MODULE_POSTGRES_BACKUP_EMAIL=$(String.explode.value $1)
                ;;
            *)
                olixmodule_postgres_params_get "${ACTION}" "$1"
                ;;
        esac
        shift
    done

    olixmodule_postgres_params_debug $ACTION
}


###
# Fonction de récupération des paramètres
# @param $1 : Nom de l'action
# @param $2 : Nom du paramètre
##
function olixmodule_postgres_params_get()
{
    case $1 in
        create)
            [[ -z $OLIX_MODULE_POSTGRES_BASE ]] && OLIX_MODULE_POSTGRES_BASE=$2 && return
            [[ -z $OLIX_MODULE_POSTGRES_OWNER ]] && OLIX_MODULE_POSTGRES_OWNER=$2 && return
            ;;
        drop)
            [[ -z $OLIX_MODULE_POSTGRES_BASE ]] && OLIX_MODULE_POSTGRES_BASE=$2 && return
            ;;
        dump)
            [[ -z $OLIX_MODULE_POSTGRES_BASE ]] && OLIX_MODULE_POSTGRES_BASE=$2 && return
            [[ -z $OLIX_MODULE_POSTGRES_DUMP ]] && OLIX_MODULE_POSTGRES_DUMP=$2 && return
            ;;
        restore)
            [[ -z $OLIX_MODULE_POSTGRES_DUMP ]] && OLIX_MODULE_POSTGRES_DUMP=$2 && return
            [[ -z $OLIX_MODULE_POSTGRES_BASE ]] && OLIX_MODULE_POSTGRES_BASE=$2 && return
            ;;
        sync)
            [[ -z $OLIX_MODULE_POSTGRES_SOURCE_HOST ]] && OLIX_MODULE_POSTGRES_SOURCE_HOST=$2 && return
            [[ -z $OLIX_MODULE_POSTGRES_SOURCE_BASE ]] && OLIX_MODULE_POSTGRES_SOURCE_BASE=$2 && return
            [[ -z $OLIX_MODULE_POSTGRES_BASE ]] && OLIX_MODULE_POSTGRES_BASE=$2 && return
            ;;
        backup)
            OLIX_MODULE_POSTGRES_BACKUP_BASES="${OLIX_MODULE_POSTGRES_BACKUP_BASES} $2"
            ;;
    esac
}


###
# Mode DEBUG
# @param $1 : Action du module
##
function olixmodule_postgres_params_debug ()
{
    debug "OLIX_MODULE_POSTGRES_HOST=${OLIX_MODULE_POSTGRES_HOST}"
    debug "OLIX_MODULE_POSTGRES_PORT=${OLIX_MODULE_POSTGRES_PORT}"
    debug "OLIX_MODULE_POSTGRES_USER=${OLIX_MODULE_POSTGRES_USER}"
    debug "OLIX_MODULE_POSTGRES_PASS=${OLIX_MODULE_POSTGRES_PASS}"
    case $1 in
        create)
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            debug "OLIX_MODULE_POSTGRES_OWNER=${OLIX_MODULE_POSTGRES_OWNER}"
            ;;
        drop)
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            ;;
        dump)
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            debug "OLIX_MODULE_POSTGRES_DUMP=${OLIX_MODULE_POSTGRES_DUMP}"
            debug "OLIX_MODULE_POSTGRES_FORMAT=${OLIX_MODULE_POSTGRES_FORMAT}"
            ;;
        restore)
            debug "OLIX_MODULE_POSTGRES_DUMP=${OLIX_MODULE_POSTGRES_DUMP}"
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            ;;
        sync)
            debug "OLIX_MODULE_POSTGRES_SOURCE_HOST=${OLIX_MODULE_POSTGRES_SOURCE_HOST}"
            debug "OLIX_MODULE_POSTGRES_SOURCE_BASE=${OLIX_MODULE_POSTGRES_SOURCE_BASE}"
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            ;;
        backup)
            debug "OLIX_MODULE_POSTGRES_BACKUP_BASES=${OLIX_MODULE_POSTGRES_BACKUP_BASES}"
            debug "OLIX_MODULE_POSTGRES_BACKUP_DIR=${OLIX_MODULE_POSTGRES_BACKUP_DIR}"
            debug "OLIX_MODULE_POSTGRES_BACKUP_PURGE=${OLIX_MODULE_POSTGRES_BACKUP_PURGE}"
            debug "OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}"
            debug "OLIX_MODULE_POSTGRES_BACKUP_REPORT=${OLIX_MODULE_POSTGRES_BACKUP_REPORT}"
            debug "OLIX_MODULE_POSTGRES_BACKUP_EMAIL=${OLIX_MODULE_POSTGRES_BACKUP_EMAIL}"
            debug "OLIX_MODULE_POSTGRES_FORMAT=${OLIX_MODULE_POSTGRES_FORMAT}"
            ;;
        bckpitr)
            debug "OLIX_MODULE_POSTGRES_PATH=${OLIX_MODULE_POSTGRES_PATH}"
            debug "OLIX_MODULE_POSTGRES_WALS=${OLIX_MODULE_POSTGRES_WALS}"
            ;;
    esac
}
