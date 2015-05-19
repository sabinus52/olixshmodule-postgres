###
# Gestion du serveur de base de données PostreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si PostreSQL est installé
# @return bool
##
function module_postgres_isInstalled()
{
    logger_debug "module_postgres_isInstalled ()"
    getent passwd postgres > /dev/null
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Test si PostreSQL est en execution
# @return bool
##
function module_postgres_isRunning()
{
    logger_debug "module_postgres_isRunning ()"
    netstat -ntpul | grep postgres > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}