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
            --dock=*)
                OLIX_MODULE_POSTGRES_DOCK=$(String.explode.value $1)
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
            --*)
                olixmodule_postgres_params_extra "${ACTION}" "$1"
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
    esac
}


###
# Fonction de récupération des paramètres postgres en plus (--*)
# @param $1 : Nom de l'action
# @param $2 : Nom du paramètre
##
function olixmodule_postgres_params_extra()
{
    OLIX_MODULE_POSTGRES_EXTRAOPTS="$OLIX_MODULE_POSTGRES_EXTRAOPTS $2"
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
    debug "OLIX_MODULE_POSTGRES_EXTRAOPTS=${OLIX_MODULE_POSTGRES_EXTRAOPTS}"
    case $1 in
        check)
            debug "OLIX_MODULE_POSTGRES_DOCK=${OLIX_MODULE_POSTGRES_DOCK}"
            ;;
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
            debug "OLIX_MODULE_POSTGRES_DOCK=${OLIX_MODULE_POSTGRES_DOCK}"
            ;;
        restore)
            debug "OLIX_MODULE_POSTGRES_DUMP=${OLIX_MODULE_POSTGRES_DUMP}"
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            debug "OLIX_MODULE_POSTGRES_DOCK=${OLIX_MODULE_POSTGRES_DOCK}"
            ;;
        sync)
            debug "OLIX_MODULE_POSTGRES_SOURCE_HOST=${OLIX_MODULE_POSTGRES_SOURCE_HOST}"
            debug "OLIX_MODULE_POSTGRES_SOURCE_BASE=${OLIX_MODULE_POSTGRES_SOURCE_BASE}"
            debug "OLIX_MODULE_POSTGRES_BASE=${OLIX_MODULE_POSTGRES_BASE}"
            ;;
    esac
}
