# olixshmodule-postgres
Module for oliXsh : Management of PostgreSQL server



### Initialisation du module

Initialiser le module

Command : `olixsh postgres init [--force]`

Entrer les informations suivantes :
- Host du serveur PostgreSQL local ou laisser *vide en mode Unix socket*
- Port du serveur PostgreSQL
- Choix d'un utilisateur pour une connexion automatique au serveur
- Choix du mot de passe pour cet utilisateur ou laisser en *vide en mode trust*



### Test de connexion au serveur PostgreSQL

Command : `olixsh postgres check [--host=<host>] [--port=5432] [--user=<user>]`

- `--host=<host>` : Host du serveur PostgreSQL
- `--port=5432` : Port du serveur PostgreSQL
- `--user=<user>` : Utilisateur de connexion au serveur PostgreSQL

Ces paramètres surchargent celles saisies lors de la commande **init** situées dans */etc/olixsh/postgres.conf*



### Dump d'une base de données PostgreSQL

Command : `olixsh postgres postgres <base> <dump_file> [--host=<host>] [--port=5432] [--user=<user>]`

- `base` : Nom de la base à sauvegarder
- `dump_file` : Emplacement et nom du fichier du dump de la base



### Restauration d'une base de données PostgreSQL

Command : `olixsh postgres restore <dump_file> <base> [--host=<host>] [--port=5432] [--user=<user>]`

- `dump_file` : Emplacement et nom du fichier à restaurer
- `base` : Nom de la base à restaurer



### Synchronisation d'une base de données PostgreSQL

Fait une copie d'une base de données d'un serveur distant (saisie en mode interactif)
vers une base sur le serveur PostgreSQL local défini dans */etc/olixsh/postgres.conf*

Command : `olixsh postgres sync <base_destination>`

- `base_destination` : Nom de la base de destination à coller



### Backup des bases d'un serveur PostgreSQL

Réalisation d'une sauvegarde des bases PostgreSQL avec rapport pour des tâches planifiées.

Command : `olixsh postgres backup [bases...] [--host=<host>] [--port=5432] [--user=<user>] [--dir=/tmp] [--purge=5] [--gz|--bz2] [--html] [--email=<name@domain.ltd>]

- `base` : Liste des bases à sauvegarder. Si omis, *toutes les bases*
- `--dir=/tmp` : Chemin de stockage des backups. Par defaut */tmp*
- `--purge=5` : Nombre de jours avant la purge des anciens backups. Par défaut *5*
- `--gz` : Compression du dump au format gzip
- `--bz2` : Compression du dump au format bzip2
- `--html` : Rapport au format HTML sinon au format TEXT par défaut
- `--email=name@domain.ltd` : Envoi du rapport à l'adresse *name@domain.ltd*

Ces derniers paramètres peuvent être insérés dans le fichier de configuration */etc/olixsh/postgres.conf* pour éviter de les mettre en paramètres dans la commande :
- `OLIX_MODULE_POSTGRES_BACKUP_DIR` : Emplacement des dumps lors de la sauvegarde
- `OLIX_MODULE_POSTGRES_BACKUP_COMPRESS` : Format de compression (`GZ`|`BZ2`)
- `OLIX_MODULE_POSTGRES_BACKUP_PURGE` : Nombre de jours de retention de la sauvegarde
- `OLIX_MODULE_POSTGRES_BACKUP_REPORT` : Format des rapports (`TEXT`|`HTML`)
- `OLIX_MODULE_POSTGRES_BACKUP_EMAIL` : Email d'envoi du rapport



### Sauvegarde à chaud en mode PITR de l'instance PostgreSQL

Réalisation d'une sauvegarde à chaud en mode PITR de l'instance PostgreSQL avec rapport pour des tâches planifiées.

Command : `olixsh postgres bckwal [path_wals] [--port=5432] [--user=<user>] [--dir=/tmp] [--purge=5] [--gz|--bz2] [--html] [--email=<name@domain.ltd>]

- `path_wals` : Emplacement des fichiers d'archive WALs à purger
- `--dir=/tmp` : Chemin de stockage des backups. Par defaut */tmp*
- `--purge=5` : Nombre de jours avant la purge des anciens backups. Par défaut *5*
- `--gz` : Compression du dump au format gzip
- `--bz2` : Compression du dump au format bzip2
- `--html` : Rapport au format HTML sinon au format TEXT par défaut
- `--email=name@domain.ltd` : Envoi du rapport à l'adresse *name@domain.ltd*

Ces derniers paramètres peuvent être insérés dans le fichier de configuration */etc/olixsh/postgres.conf* pour éviter de les mettre en paramètres dans la commande :



