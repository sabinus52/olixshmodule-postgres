# olixshmodule-postgres
Module for oliXsh : Management of PostgreSQL server


**INFO** : La plupart des paramètres peuvent être configurés dans le fichier */etc/olixsh/postgres.conf* ou via la commande *setcfg*

Pour réaliser une sauvegarde ou une restauration d'une base de données depuis un containeur Docker PostgreSQL, il suffit d'utiliser la paramètre `dock`


### Test de connexion au serveur PostgreSQL

Command : `olixsh postgres check [--host=<host>] [--port=5432] [--user=<user>]  [--dock=<container>]`

- `--host=<host>` : Host du serveur PostgreSQL
- `--port=5432` : Port du serveur PostgreSQL
- `--user=<user>` : Utilisateur de connexion au serveur PostgreSQL
- `--dock=<container>` : Nom du containeur Docker PostgreSQL

Ces paramètres surchargent celles saisies lors de la commande **init** situées dans */etc/olixsh/postgres.conf*



### Dump d'une base de données PostgreSQL

Command : `olixsh postgres postgres <base> <dump_file> [--format=c|t|d|p] [--host=<host>] [--port=5432] [--user=<user>] [--dock=<container>]`

- `base` : Nom de la base à sauvegarder
- `dump_file` : Emplacement et nom du fichier du dump de la base
- `--format` : Format du dump (personnalisé, archive, répertoire, mode sql)

Exemple :
~~~ bash
# Sauvegarde en utilisant les paramètres de connexion définis dans le fichier /etc/olixsh/postgres.conf
olixsh postgres dump toto /tmp/toto.sql
# Sauvegarde en utilisant l'utilisateur titi
olixsh postgres dump toto /tmp/toto.sql --user=titi
# Sauvegarde de la base toto à travers le containeur casimir et l'utilisateur titi
olixsh postgres dump toto /tmp/toto.sql --dock=casimir --user=titi
~~~


### Restauration d'une base de données PostgreSQL

Command : `olixsh postgres restore <dump_file> <base> [--host=<host>] [--port=5432] [--user=<user>] [--dock=<container>]`

- `dump_file` : Emplacement et nom du fichier à restaurer
- `base` : Nom de la base à restaurer

NB : La base sera supprimée puis recréée avec le même propriétaire

Exemple :
~~~ bash
# Restauration en utilisant les paramètres de connexion définis dans le fichier /etc/olixsh/postgres.conf
olixsh postgres restore /tmp/toto.sql toto
# Restauration en utilisant l'utilisateur titi
olixsh postgres restore /tmp/toto.sql toto --user=titi
# Restauration de la base toto à travers le containeur casimir et l'utilisateur titi
olixsh postgres restore /tmp/toto.sql toto --dock=casimir --user=titi
~~~


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
