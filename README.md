# olixshmodule-postgres
Module for oliXsh : Management of PostgreSQL server


**INFO** : La plupart des paramètres peuvent être configurés dans le fichier */etc/olixsh/postgres.conf* ou via la commande *setcfg*


### Test de connexion au serveur PostgreSQL

Command : `olixsh postgres check [--host=<host>] [--port=5432] [--user=<user>]`

- `--host=<host>` : Host du serveur PostgreSQL
- `--port=5432` : Port du serveur PostgreSQL
- `--user=<user>` : Utilisateur de connexion au serveur PostgreSQL

Ces paramètres surchargent celles saisies lors de la commande **init** situées dans */etc/olixsh/postgres.conf*



### Dump d'une base de données PostgreSQL

Command : `olixsh postgres postgres <base> <dump_file> [--format=c|t|d|p] [--host=<host>] [--port=5432] [--user=<user>]`

- `base` : Nom de la base à sauvegarder
- `dump_file` : Emplacement et nom du fichier du dump de la base
- `--format` : Format du dump (personnalisé, archive, répertoire, mode sql)



### Restauration d'une base de données PostgreSQL

Command : `olixsh postgres restore <dump_file> <base> [--host=<host>] [--port=5432] [--user=<user>]`

- `dump_file` : Emplacement et nom du fichier à restaurer
- `base` : Nom de la base à restaurer

NB : La base sera supprimée puis recréée avec le même propriétaire



### Création d'une base de données PostgreSQL

Command : `olixsh postgres create <base> <owner> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à créer
- `owner` : Nom du propriétaire de la base (s'il n'existe pas, il sera créé)


### Suppression d'une base de données PostgreSQL

Command : `olixsh postgres drop <base> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à supprimer



### Synchronisation d'une base de données PostgreSQL

Fait une copie d'une base de données d'un serveur distant
vers une base sur le serveur PostgreSQL local défini dans */etc/olixsh/postgres.conf*

Command : `olixsh postgres sync <user@host[:port]> <base_source> <base_destination>`

- `base_destination` : Nom de la base de destination à coller
- `user@host[:port]` : Info de connexion au serveur PostgreSQL distant
- `base_source` : Nom de la base de source du serveur distant



### Backup des bases d'un serveur PostgreSQL

Réalisation d'une sauvegarde des bases PostgreSQL avec rapport pour des tâches planifiées.

Command : `olixsh postgres backup [bases...] [--format=c|t|d|p] [--host=<host>] [--port=5432] [--user=<user>] [--dir=/tmp] [--purge=5] [--gz|--bz2] [--html] [--email=<name@domain.ltd>]

- `base` : Liste des bases à sauvegarder. Si omis, *toutes les bases*
- `--format=c` : Format du dump (personnalisé, archive, répertoire, mode sql)
- `--dir=/tmp` : Chemin de stockage des backups. Par defaut */tmp*
- `--purge=5` : Nombre de jours avant la purge des anciens backups. Par défaut *5*
- `--gz` : Compression du dump au format gzip
- `--bz2` : Compression du dump au format bzip2
- `--html` : Rapport au format HTML sinon au format TEXT par défaut
- `--email=name@domain.ltd` : Envoi du rapport à l'adresse *name@domain.ltd*



### Sauvegarde à chaud en mode PITR de l'instance PostgreSQL

Réalisation d'une sauvegarde à chaud en mode PITR de l'instance PostgreSQL avec rapport pour des tâches planifiées.

Command : `olixsh postgres bckwal [--pgdata=<path_instance>] [--wals=<path_wals>] [--port=5432] [--user=<user>] [--dir=/tmp] [--purge=5] [--gz|--bz2] [--html] [--email=<name@domain.ltd>]

- `--pgdata=` : Emplacement de l'instance PostgreSQL
- `--wals=` : Emplacement des fichiers d'archive WALs à purger
- `--dir=/tmp` : Chemin de stockage des backups. Par defaut */tmp*
- `--purge=5` : Nombre de jours avant la purge des anciens backups. Par défaut *5*
- `--gz` : Compression du dump au format gzip
- `--bz2` : Compression du dump au format bzip2
- `--html` : Rapport au format HTML sinon au format TEXT par défaut
- `--email=name@domain.ltd` : Envoi du rapport à l'adresse *name@domain.ltd*

