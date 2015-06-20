# olixshmodule-postgres
Module for oliXsh : Management of PostgreSQL server


### Paramètres obligatoires de configuration du module
OLIX_MODULE_POSTGRES_HOST            : Nom du serveur Postgres (Vide en mode socket Unix)
OLIX_MODULE_POSTGRES_PORT            : Numéro du port Postgres
OLIX_MODULE_POSTGRES_USER            : Nom de l'utilisateur Postgres
OLIX_MODULE_POSTGRES_PASS            : Mot de passe de l'utilisateur (peut être vide si configuration du fichier pg_hba.conf)
OLIX_MODULE_POSTGRES_PATH            : Chemin des données de l'instance Postgres

### Paramètres optionnels de configuration du module
OLIX_MODULE_POSTGRES_BACKUP_DIR      : Emplacement des dumps lors de la sauvegarde
OLIX_MODULE_POSTGRES_BACKUP_COMPRESS : Format de compression
OLIX_MODULE_POSTGRES_BACKUP_PURGE    : Nombre de jours de retention de la sauvegarde
OLIX_MODULE_POSTGRES_BACKUP_REPORT   : Format des rapports
OLIX_MODULE_POSTGRES_BACKUP_EMAIL    : Email d'envoi de rapport

Ces paramètres peuvent être ajoutés dans le fichier `conf/mysql.conf`