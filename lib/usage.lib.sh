###
# Usage du module POSTGRES
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function module_postgres_usage_main()
{
    logger_debug "module_postgres_usage_main ()"
    stdout_printVersion
    echo
    echo -e "Gestion des bases de données PostgreSQL (sauvegarde, restauration, ...)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}postgres ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du module"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}
