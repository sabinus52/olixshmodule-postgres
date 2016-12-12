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

# Si aucune base définie, on récupère toutes les bases
if [[ -z $OLIX_MODULE_POSTGRES_BACKUP_BASES ]]; then
    OLIX_MODULE_POSTGRES_BACKUP_BASES=$(Postgres.server.databases)
fi

if [[ ! -d $OLIX_MODULE_POSTGRES_BACKUP_DIR ]]; then
    warning "Création du dossier inexistant OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
    mkdir $OLIX_MODULE_POSTGRES_BACKUP_DIR || critical "Impossible de créer OLIX_MODULE_POSTGRES_BACKUP_DIR: \"${OLIX_MODULE_POSTGRES_BACKUP_DIR}\""
elif [[ ! -w ${OLIX_MODULE_POSTGRES_BACKUP_DIR} ]]; then
    critical "Le dossier '${OLIX_MODULE_POSTGRES_BACKUP_DIR}' n'a pas les droits en écriture"
fi


###
# Initialisation
##
[[ "${OLIX_MODULE_POSTGRES_FORMAT:0:1}" != "p" ]] && OLIX_MODULE_POSTGRES_BACKUP_COMPRESS=null
Backup.initialize "$OLIX_MODULE_POSTGRES_BACKUP_DIR" "$OLIX_MODULE_POSTGRES_BACKUP_COMPRESS" "$OLIX_MODULE_POSTGRES_BACKUP_PURGE"
Report.initialize "$OLIX_MODULE_POSTGRES_BACKUP_REPORT" \
    "$OLIX_MODULE_POSTGRES_BACKUP_DIR" "rapport-dump-postgres" "$OLIX_MODULE_POSTGRES_BACKUP_PURGE" \
    "$OLIX_MODULE_POSTGRES_BACKUP_EMAIL"

Print.head1 "Sauvegarde des bases PostgreSQL %s le %s à %s" "$HOSTNAME" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"


###
# Traitement
##

# Sauvegarde des objets globaux
PGGLOBAL="$(Backup.path)/backup-pg-global-$OLIX_SYSTEM_DATE.sql"
info "Sauvegarde des objects globaux de l'instance -> ${PGGLOBAL}"
Postgres.server.dump.objects $PGGLOBAL
Print.result $? "Sauvegarde des objects globaux" "$(File.size.human $PGGLOBAL)" "$((SECONDS-START))"
if [[ $? -ne 0 ]]; then
    error && IS_ERROR=true
else
    Backup.continue $PGGLOBAL 'backup-pg-global-'
    [[ $? -ne 0 ]] && IS_ERROR=true
fi

# Dump de chaque base
for BASE in $OLIX_MODULE_POSTGRES_BACKUP_BASES; do
    info "Sauvegarde de la base '$BASE'"
    Postgres.base.backup $BASE $OLIX_MODULE_POSTGRES_FORMAT
    [[ $? -ne 0 ]] && IS_ERROR=true
done


###
# FIN
##
if [[ $IS_ERROR == true ]]; then
    Print.echo; Print.line; Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec des erreurs" "${Crouge}"
    Report.terminate "ERREUR - Rapport de backup des bases du serveur $HOSTNAME"
else
    Print.echo; Print.line; Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec succès" "${Cvert}"
    Report.terminate "Rapport de backup des bases du serveur $HOSTNAME"
fi
