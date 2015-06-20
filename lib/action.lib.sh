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
    stdin_read "Host du serveur PostgreSQL (vide en mode Unix socket)" "${OLIX_MODULE_POSTGRES_HOST}"
    logger_debug "OLIX_MODULE_POSTGRES_HOST=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_HOST=${OLIX_STDIN_RETURN}
    
    # Port
    stdin_read "Host du serveur PostgreSQL" "${OLIX_MODULE_POSTGRES_PORT}"
    logger_debug "OLIX_MODULE_POSTGRES_PORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_PORT=${OLIX_STDIN_RETURN}
    
    # Utilisateur
    stdin_read "Utilisateur de la base PostgreSQL" "${OLIX_MODULE_POSTGRES_USER}"
    logger_debug "OLIX_MODULE_POSTGRES_USER=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_USER=${OLIX_STDIN_RETURN}

    # Mot de passe
    stdin_readPassword "Mot de passe du serveur PostgreSQL"
    logger_debug "OLIX_MODULE_POSTGRES_PASS=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_PASS=${OLIX_STDIN_RETURN}

    # Emplacement de l'instance
    stdin_readDirectory "Chemin complet de l'instance PostgreSQL" "${OLIX_MODULE_POSTGRES_PATH}" false
    logger_debug "OLIX_MODULE_POSTGRES_PATH=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_POSTGRES_PATH=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${OLIX_MODULE_FILECONF}"
    echo "# Fichier de configuration du module POSTGRES" > ${OLIX_MODULE_FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_POSTGRES_HOST=${OLIX_MODULE_POSTGRES_HOST}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_PORT=${OLIX_MODULE_POSTGRES_PORT}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_USER=${OLIX_MODULE_POSTGRES_USER}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_PASS=${OLIX_MODULE_POSTGRES_PASS}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_POSTGRES_PATH=${OLIX_MODULE_POSTGRES_PATH}" >> ${OLIX_MODULE_FILECONF}

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


###
# Fait un backup complet des bases Postgres
# @param $@ : Liste des bases à sauvegarder
##
function module_postgres_action_backup()
{
    logger_debug "module_postgres_action_backup ($@)"
    local IS_ERROR=false

    # Si aucune base définie, on récupère toutes les bases
    if [[ -z ${OLIX_MODULE_POSTGRES_BACKUP_BASES} ]]; then
        OLIX_MODULE_POSTGRES_BACKUP_BASES=$(module_postgres_getListDatabases)
    fi
    if [[ ! -d ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]]; then
        logger_warning "Création du dossier inexistant OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
        mkdir ${OLIX_MODULE_POSTGRES_BACKUP_DIR} || logger_error "Impossible de créer OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
    elif [[ ! -w ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]]; then
        logger_error "Le dossier '${OLIX_MODULE_POSTGRES_BACKUP_DIR}' n'a pas les droits en écriture"
    fi

    source lib/backup.lib.sh
    source lib/report.lib.sh

    # Mise en place du rapport
    report_initialize "${OLIX_MODULE_POSTGRES_BACKUP_REPORT}" \
                      "${OLIX_MODULE_POSTGRES_BACKUP_DIR}" "rapport-dump-postgres-${OLIX_SYSTEM_DATE}" \
                      "${OLIX_MODULE_POSTGRES_BACKUP_EMAIL}"
    stdout_printHead1 "Sauvegarde des bases PostgreSQL %s le %s à %s" "${HOSTNAME}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"

    # Sauvegarde des objets globaux
    local PGGLOBAL="${OLIX_MODULE_POSTGRES_BACKUP_DIR}/pg-global-${OLIX_SYSTEM_DATE}.sql"
    logger_info "Sauvegarde des objects globaux de l'instance -> ${PGGLOBAL}"
    module_postgres_dumpOnlyGlobalObjects "${PGGLOBAL}"
    stdout_printMessageReturn $? "Sauvegarde des objects globaux" "$(filesystem_getSizeFileHuman ${PGGLOBAL})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_warning && IS_ERROR=true
    backup_finalize "${PGGLOBAL}" "${OLIX_MODULE_POSTGRES_BACKUP_DIR}" "${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}" "${OLIX_MODULE_POSTGRES_BACKUP_PURGE}" "pg-global-*" false
    [[ $? -ne 0 ]] && IS_ERROR=true

    # Sauvegarde de chaque base
    local I
    for I in ${OLIX_MODULE_POSTGRES_BACKUP_BASES}; do
        logger_info "Sauvegarde de la base '${I}'"
        module_postgres_backupDatabase "${I}" "${OLIX_MODULE_POSTGRES_BACKUP_DIR}" "${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}" "${OLIX_MODULE_POSTGRES_BACKUP_PURGE}" false
        [[ $? -ne 0 ]] && IS_ERROR=true
    done

    stdout_print; stdout_printLine; stdout_print "Sauvegarde terminée en $(core_getTimeExec) secondes" "${Cvert}"

    if [[ ${IS_ERROR} == true ]]; then
        report_terminate "ERREUR - Rapport de backups des bases du serveur ${HOSTNAME}"
    else
        report_terminate "Rapport de backups des bases du serveur ${HOSTNAME}"
    fi
}



###
# Fait un backup des WAL en mode PITR
##
function module_postgres_action_bckwal()
{
    logger_debug "module_postgres_action_bckwal ($@)"
    local IS_ERROR=false
    local RET

    if [[ ! -d ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]]; then
        logger_warning "Création du dossier inexistant OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
        mkdir ${OLIX_MODULE_POSTGRES_BACKUP_DIR} || logger_error "Impossible de créer OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
    elif [[ ! -w ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]]; then
        logger_error "Le dossier '${OLIX_MODULE_POSTGRES_BACKUP_DIR}' n'a pas les droits en écriture"
    fi

    source lib/backup.lib.sh
    source lib/report.lib.sh

    # Mise en place du rapport
    report_initialize "${OLIX_MODULE_POSTGRES_BACKUP_REPORT}" \
                      "${OLIX_MODULE_POSTGRES_BACKUP_DIR}" "rapport-pgwals-${OLIX_SYSTEM_DATE}" \
                      "${OLIX_MODULE_POSTGRES_BACKUP_EMAIL}"
    stdout_printHead1 "Sauvegarde à chaud de l'instance PostgreSQL %s le %s à %s" "${HOSTNAME}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"

    # PITR de début
    logger_info "Signalisation à Postgres du début de la sauvegarde"
    module_postgres_execSQL "SELECT pg_start_backup('archivelog');"
    stdout_printMessageReturn $? "Signalisation à Postgres du début de la sauvegarde" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_warning && IS_ERROR=true

    # Sauvegarde des objets globaux
    local BACKUP="${OLIX_MODULE_POSTGRES_BACKUP_DIR}/backup-pgwals-${OLIX_SYSTEM_DATE}.tar"
    logger_info "Création de l'archive -> ${BACKUP}"
    file_makeArchive "${OLIX_MODULE_POSTGRES_PATH}" "${BACKUP}" "" "--ignore-failed-read"
    RET=$?
    [[ ${RET} -eq 1 ]] && logger_warning && RET=0
    stdout_printMessageReturn ${RET} "Sauvegarde des fichiers de l'instance" "$(filesystem_getSizeFileHuman ${BACKUP})" "$((SECONDS-START))"
    [[ ${RET} -ne 0 ]] && logger_warning && IS_ERROR=true
    backup_finalize "${BACKUP}" "${OLIX_MODULE_POSTGRES_BACKUP_DIR}" "${OLIX_MODULE_POSTGRES_BACKUP_COMPRESS}" "${OLIX_MODULE_POSTGRES_BACKUP_PURGE}" "backup-pgwals-*" false
    [[ $? -ne 0 ]] && IS_ERROR=true

    # PITR de fin
    logger_info "Signalisation à Postgres de la fin de la sauvegarde"
    module_postgres_execSQL "SELECT pg_stop_backup();"
    stdout_printMessageReturn $? "Signalisation à Postgres de la fin de la sauvegarde" "" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && logger_warning && IS_ERROR=true

    stdout_print; stdout_printLine; stdout_print "Sauvegarde terminée en $(core_getTimeExec) secondes" "${Cvert}"

    if [[ ${IS_ERROR} == true ]]; then
        report_terminate "ERREUR - Rapport de backup à chaud du serveur PostgreSQL ${HOSTNAME}"
    else
        report_terminate "Rapport de backup à chaud du serveur PostgreSQL ${HOSTNAME}"
    fi
}

