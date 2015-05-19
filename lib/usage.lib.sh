###
# Usage du module POSTGRES
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function module_postgres_usage_main()
{
    logger_debug "module_postgres_usage_main ()"
    stdout_printVersion
    echo
    echo -e "Gestion des bases de données PostgreSQL (sauvegarde, restauration, ...)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}postgres ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du module"
    echo -e "${Cjaune} dump    ${CVOID}  : Fait un dump d'une base de données"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action DUMP
##
function module_postgres_usage_dump()
{
    logger_debug "module_postgres_usage_dump ()"
    stdout_printVersion
    echo
    echo -e "Faire un dump d'une base de données PostreSQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}postgres ${CJAUNE}dump${CVOID} ${CBLANC}base dumpfile [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=${OLIX_MODULE_POSTGRES_HOST} ${CVOID}"; stdout_strpad "${OLIX_MODULE_POSTGRES_HOST}" 13 " "; echo " : Host du serveur POSTGRES"
    echo -en "${CBLANC} --port=${OLIX_MODULE_POSTGRES_PORT} ${CVOID}"; stdout_strpad "${OLIX_MODULE_POSTGRES_PORT}" 13 " "; echo " : Port du serveur POSTGRES"
    echo -en "${CBLANC} --user=${OLIX_MODULE_POSTGRES_USER} ${CVOID}"; stdout_strpad "${OLIX_MODULE_POSTGRES_USER}" 13 " "; echo " : User du serveur POSTGRES"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_postgres_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Retourne les paramètres de la commandes en fonction des options
# @param $@ : Liste des paramètres
##
function module_postgres_usage_getParams()
{
    logger_debug module_postgres_usage_getParams
    local PARAM

    while [[ $# -ge 1 ]]; do
        case $1 in
            --host=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_POSTGRES_HOST=${PARAM[1]}
                ;;
            --port=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_POSTGRES_PORT=${PARAM[1]}
                ;;
            --user=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_POSTGRES_USER=${PARAM[1]}
                ;;
            --dir=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_POSTGRES_BACKUP_DIR=${PARAM[1]}
                ;;
            --purge=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_POSTGRES_BACKUP_PURGE=${PARAM[1]}
                ;;
            --gz|--bz2)
                OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${1/--/}
                ;;
            --html)
                OLIX_MODULE_POSTGRES_BACKUP_REPORT="HTML"
                ;;
            --email=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_POSTGRES_BACKUP_EMAIL=${PARAM[1]}
                ;;
            *)
                OLIX_MODULE_POSTGRES_BACKUP_BASES="${OLIX_MODULE_POSTGRES_BACKUP_BASES} $1"
                [[ -n ${OLIX_MODULE_POSTGRES_PARAM1} ]] && OLIX_MODULE_POSTGRES_PARAM2=$1
                [[ -z ${OLIX_MODULE_POSTGRES_PARAM1} ]] && OLIX_MODULE_POSTGRES_PARAM1=$1
                ;;
        esac
        shift
    done
    config_require "OLIX_MODULE_POSTGRES_BACKUP_DIR" "/tmp"
    config_require "OLIX_MODULE_POSTGRES_BACKUP_PURGE" "5"
    config_require "OLIX_MODULE_POSTGRES_BACKUP_REPORT" "TEXT"
    logger_debug "OLIX_MODULE_POSTGRES_HOST=${OLIX_MODULE_POSTGRES_HOST}"
    logger_debug "OLIX_MODULE_POSTGRES_PORT=${OLIX_MODULE_POSTGRES_PORT}"
    logger_debug "OLIX_MODULE_POSTGRES_USER=${OLIX_MODULE_POSTGRES_USER}"
    logger_debug "OLIX_MODULE_POSTGRES_PARAM1=${OLIX_MODULE_POSTGRES_PARAM1}"
    logger_debug "OLIX_MODULE_POSTGRES_PARAM2=${OLIX_MODULE_POSTGRES_PARAM2}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_DIR=${OLIX_MODULE_POSTGRES_BACKUP_DIR}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_PURGE=${OLIX_MODULE_POSTGRES_BACKUP_PURGE}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_REPORT=${OLIX_MODULE_POSTGRES_BACKUP_REPORT}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_EMAIL=${OLIX_MODULE_POSTGRES_BACKUP_EMAIL}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_BASES=${OLIX_MODULE_POSTGRES_BACKUP_BASES}"
}
