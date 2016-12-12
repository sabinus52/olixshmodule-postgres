###
# Fichier obligatoire contenant la configuration et l'initialisation du module
# ==============================================================================
# @package olixsh
# @module postgres
# @label Utilitaires pour les bases postgreSQL
# @author Olivier <sabinus52@gmail.com>
##



###
# Paramètres du modules
##



###
# Chargement des librairies requis
##
olixmodule_postgres_require_libraries()
{
    load "modules/postgres/conf/params.sh"
    load "modules/postgres/lib/*"
}


###
# Retourne la liste des modules requis
##
olixmodule_postgres_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmodule_postgres_require_binary()
{
    echo -e "psql pg_dump pg_restore"
}


###
# Traitement à effectuer au début d'un traitement
##
olixmodule_postgres_include_begin()
{
    olixmodule_postgres_params_parse $@
}


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_postgres_include_end()
# {
#    echo "FIN"
# }


###
# Sortie de liste pour la completion
##
olixmodule_postgres_list()
{
    Postgres.server.check || return
    Postgres.server.databases
}
