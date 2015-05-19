###
# Module de la gestion des bases PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="postgres"


###
# Retourne la liste des modules requis
##
olixmod_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmod_require_binary()
{
    echo -e "psql pg_dump pg_restore"
}


###
# Usage de la commande
##
olixmod_usage()
{
    logger_debug "module_postgres__olixmod_usage ()"

    source modules/postgres/lib/usage.lib.sh

    module_postgres_usage_main
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_postgres__olixmod_list ($@)"
}


###
# Initialisation du module
##
olixmod_init()
{
    logger_debug "module_postgres__olixmod_init (null)"
    source modules/postgres/lib/postgres.lib.sh
    source modules/postgres/lib/action.lib.sh
    module_postgres_action_init $@
}


###
# Function principale
##
olixmod_main()
{
    logger_debug "module_postgres__olixmod_main ($@)"
    local ACTION=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixmod_usage && core_exit 1
    [[ "$1" == "help" ]] && olixmod_usage && core_exit 0

    # Librairies necessaires
    source lib/stdin.lib.sh
    source lib/filesystem.lib.sh
    source lib/file.lib.sh
    source modules/postgres/lib/postgres.lib.sh
    source modules/postgres/lib/usage.lib.sh
    source modules/postgres/lib/action.lib.sh

    if ! type "module_postgres_action_$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    
    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide de l'action
    [[ "$2" == "help" && "$1" != "init" ]] && module_postgres_usage_$ACTION && core_exit 0

    shift
    module_postgres_usage_getParams $@
    module_postgres_action_$ACTION $@
}
