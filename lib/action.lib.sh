###
# Librairies des actions du module POSTGRES
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##



###
# Initialisation du module en créant le fichier de configuration
# @var OLIX_MODULE_postgres_*
##
function module_postgres_action_init()
{
    logger_debug "module_postgres_action_init ($@)"

    # Host
    stdin_read "Host du serveur PostgreSQL (vide en mode socket)" "${OLIX_MODULE_POSTGRES_HOST}"
    logger_debug "OLIX_MODULE_POSTGRES_HOST=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_HOST=${OLIX_STDIN_RETURN}
    
    # Port
    [[ -z ${OLIX_MODULE_POSTGRES_PORT} ]] && OLIX_MODULE_POSTGRES_PORT="5432"
    stdin_read "Host du serveur PostgreSQL" "${OLIX_MODULE_POSTGRES_PORT}"
    logger_debug "OLIX_MODULE_POSTGRES_PORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_PORT=${OLIX_STDIN_RETURN}
    
    # Utilisateur
    [[ -z ${OLIX_MODULE_POSTGRES_USER} ]] && OLIX_MODULE_POSTGRES_USER=postgres
    stdin_read "Utilisateur de la base PostgreSQL" "${OLIX_MODULE_POSTGRES_USER}"
    logger_debug "OLIX_MODULE_POSTGRES_USER=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_USER=${OLIX_STDIN_RETURN}

    # Mot de passe
    stdin_readDoublePassword "Mot de passe du serveur PostgreSQL"
    logger_debug "OLIX_MODULE_POSTGRES_PASS=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_PASS=${OLIX_STDIN_RETURN}

    # Emplacement des dumps lors de la sauvegarde
    [[ -z ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]] && OLIX_MODULE_POSTGRES_BACKUP_DIR="/tmp"
    stdin_readDirectory "Chemin complet des dumps de sauvegarde" "${OLIX_MODULE_POSTGRES_BACKUP_DIR}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_DIR=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_BACKUP_DIR=${OLIX_STDIN_RETURN}

    # Format de compression
    [[ -z ${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS} ]] && OLIX_MODULE_POSTGRES_BACKUP_COMPRESS="GZ"
    stdin_readSelect "Format de compression des dumps (NULL pour sans compression)" "NULL null GZ gz BZ2 bz2" "${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${OLIX_STDIN_RETURN}

    # Nombre de jours de retention de la sauvegarde
    [[ -z ${OLIX_MODULE_POSTGRES_BACKUP_PURGE} ]] && OLIX_MODULE_POSTGRES_BACKUP_PURGE="5"
    stdin_readSelect "Retention des dumps de sauvegarde" "LOG log 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31" "${OLIX_MODULE_POSTGRES_BACKUP_PURGE}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_PURGE=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_BACKUP_PURGE=${OLIX_STDIN_RETURN}

    # Format du rapport
    [[ -z ${OLIX_MODULE_POSTGRES_BACKUP_REPORT} ]] && OLIX_MODULE_POSTGRES_BACKUP_REPORT="TEXT"
    stdin_readSelect "Format des rapports de sauvegarde" "TEXT text HTML html" "${OLIX_MODULE_POSTGRES_BACKUP_REPORT}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_REPORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_BACKUP_REPORT=${OLIX_STDIN_RETURN}

    # Email d'envoi de rapport
    stdin_read "Email d'envoi du rapport" "${OLIX_MODULE_POSTGRES_BACKUP_EMAIL}"
    logger_debug "OLIX_MODULE_POSTGRES_BACKUP_EMAIL=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_BACKUP_EMAIL=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${OLIX_MODULE_FILECONF}"
    echo "# Fichier de configuration du module POSTGRES" > ${OLIX_MODULE_FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_POSTGRES_HOST=${OLIX_MODULE_POSTGRES_HOST}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_PORT=${OLIX_MODULE_POSTGRES_PORT}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_USER=${OLIX_MODULE_POSTGRES_USER}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_PASS=${OLIX_MODULE_POSTGRES_PASS}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_BACKUP_DIR=${OLIX_MODULE_POSTGRES_BACKUP_DIR}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_BACKUP_PURGE=${OLIX_MODULE_POSTGRES_BACKUP_PURGE}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_BACKUP_REPORT=${OLIX_MODULE_POSTGRES_BACKUP_REPORT}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_BACKUP_EMAIL=${OLIX_MODULE_POSTGRES_BACKUP_EMAIL}" >> ${OLIX_MODULE_FILECONF}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Fait un dump d'une base de données
##
function module_postgres_action_dump()
{
    logger_debug "module_postgres_action_dump ($@)"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_postgres_usage_dump && core_exit 1

    # Vérifie les paramètres
    filesystem_isCreateFile "${OLIX_MODULE_POSTGRES_PARAM2}"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le fichier '${OLIX_MODULE_POSTGRES_PARAM2}'"
    
    logger_info "Dump de la base '${OLIX_MODULE_POSTGRES_PARAM1}' vers le fichier '${OLIX_MODULE_POSTGRES_PARAM2}'"
    module_postgres_dumpDatabase ${OLIX_MODULE_POSTGRES_PARAM1} ${OLIX_MODULE_POSTGRES_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec du dump de la base '${OLIX_MODULE_POSTGRES_PARAM1}' vers le fichier '${OLIX_MODULE_POSTGRES_PARAM2}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Fait une restauration d'un dump
##
function module_postgres_action_restore()
{
    logger_debug "module_postgres_action_restore ($@)"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_postgres_usage_restore && core_exit 1

    # Vérifie les paramètres
    [[ ! -r ${OLIX_MODULE_POSTGRES_PARAM1} ]] && logger_error "Le fichier '${OLIX_MODULE_POSTGRES_PARAM1}' est absent ou inaccessible"
    
    logger_info "Restauration du dump '${OLIX_MODULE_POSTGRES_PARAM1}' vers la base '${OLIX_MODULE_POSTGRES_PARAM2}'"
    module_postgres_restoreDatabase ${OLIX_MODULE_POSTGRES_PARAM1} ${OLIX_MODULE_POSTGRES_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec de la restauration du dump '${OLIX_MODULE_POSTGRES_PARAM1}' vers la base '${OLIX_MODULE_POSTGRES_PARAM2}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}



###
# Synchronise une base de données depuis un serveur distant
##
function module_postgres_action_sync()
{
    logger_debug "module_postgres_action_sync ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_postgres_usage_sync && core_exit 1

    module_postgres_isBaseExists "${OLIX_MODULE_POSTGRES_PARAM1}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_POSTGRES_PARAM1}' n'existe pas"

    # Demande des infos de connexion à la base distante
    stdin_readConnexionServer "" "5432" "postgres"

    echo "Choix de la base de données source"
    module_postgres_usage_readDatabase "${OLIX_STDIN_RETURN_HOST}" "${OLIX_STDIN_RETURN_PORT}" "${OLIX_STDIN_RETURN_USER}" "${OLIX_STDIN_RETURN_PASS}"
    OLIX_MODULE_POSTGRES_PARAM2=${OLIX_STDIN_RETURN}

    if [[ -n ${OLIX_MODULE_POSTGRES_PARAM2} ]]; then
        logger_info "Synchronisation de la base '${OLIX_STDIN_RETURN_HOST}:${OLIX_MODULE_POSTGRES_PARAM2}' vers '${OLIX_MODULE_POSTGRES_PARAM1}'"
        module_postgres_synchronizeDatabase \
            "--host=${OLIX_STDIN_RETURN_HOST} --port=${OLIX_STDIN_RETURN_PORT} --username=${OLIX_STDIN_RETURN_USER}" \
            "${OLIX_MODULE_POSTGRES_PARAM2}" \
            "--host=${OLIX_MODULE_POSTGRES_HOST} --port=${OLIX_MODULE_POSTGRES_PORT} --username=${OLIX_MODULE_POSTGRES_USER}" \
            "${OLIX_MODULE_POSTGRES_PARAM1}"
        [[ $? -ne 0 ]] && logger_error "Echec de la synchronisation de '${OLIX_STDIN_RETURN_HOST}:${OLIX_MODULE_POSTGRES_PARAM2}' vers '${OLIX_MODULE_POSTGRES_PARAM1}'"
        echo -e "${Cvert}Action terminée avec succès${CVOID}"
    fi
}
