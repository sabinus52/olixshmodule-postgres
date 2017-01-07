###
# Sauvegarde complète des bases de données d'un serveur PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##
load "utils/backup.sh"
load "utils/report.sh"



###
# Vérification des paramètres
##
IS_ERROR=false

if [[ ! -d $OLIX_MODULE_POSTGRES_BACKUP_DIR ]]; then
    warning "Création du dossier inexistant OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
    mkdir $OLIX_MODULE_POSTGRES_BACKUP_DIR || critical "Impossible de créer OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
elif [[ ! -w ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]]; then
    critical "Le dossier '${OLIX_MODULE_POSTGRES_BACKUP_DIR}' n'a pas les droits en écriture"
fi


###
# Initialisation
##
Backup.initialize "$OLIX_MODULE_POSTGRES_BACKUP_DIR" null "$OLIX_MODULE_POSTGRES_BACKUP_PURGE"
Report.initialize "$OLIX_MODULE_POSTGRES_BACKUP_REPORT" \
    "$OLIX_MODULE_POSTGRES_BACKUP_DIR" "rapport-bckpitr" "$OLIX_MODULE_POSTGRES_BACKUP_PURGE" \
    "$OLIX_MODULE_POSTGRES_BACKUP_EMAIL"

Print.head1 "Sauvegarde à chaud de l'instance PostgreSQL %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"



###
# Traitement
##
PGBACKUP="$(Backup.path)/backup-pitr-${OLIX_SYSTEM_DATE}"
case $(String.lower $OLIX_MODULE_POSTGRES_BACKUP_COMPRESS) in
    bz|bz2) PGBACKUP="$PGBACKUP.tbz";;
    gz)     PGBACKUP="$PGBACKUP.tgz";;
esac
info "Création de l'archive -> ${PGBACKUP}"

Postgres.action.backup.pitr $OLIX_MODULE_POSTGRES_PATH $PGBACKUP $OLIX_MODULE_POSTGRES_BACKUP_COMPRESS
Print.result $? "Sauvegarde des fichiers de l'instance" "$(File.size.human $PGBACKUP)" "$((SECONDS-START))"
if [[ $? -ne 0 ]]; then
    error ; IS_ERROR=true
else
    Backup.continue $PGBACKUP 'backup-pitr-'
    [[ $? -ne 0 ]] && IS_ERROR=true
fi


# Purge des archives des WALS
if [[ -d $OLIX_MODULE_POSTGRES_WALS ]]; then
    info "Purge des anciennes archives des fichiers WALS"
    Postgres.action.wals.purge $OLIX_MODULE_POSTGRES_WALS $OLIX_MODULE_POSTGRES_BACKUP_PURGE
    [[ $? -ne 0 ]] && error && IS_ERROR=true
fi



###
# FIN
##
if [[ $IS_ERROR == true ]]; then
    Print.echo; Print.line; Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec des erreurs" "${Crouge}"
    Report.terminate "ERREUR - Rapport de backup à chaud du serveur PostgreSQL $HOSTNAME"
else
    Print.echo; Print.line; Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec succès" "${Cvert}"
    Report.terminate "Rapport de backup à chaud du serveur PostgreSQL $HOSTNAME"
fi
