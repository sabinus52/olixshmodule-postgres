###
# Usage du module POSTGRES
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale du module
##
function olixmodule_postgres_usage_main()
{
    debug "olixmodule_postgres_usage_main ()"
    echo
    echo -e "Gestion des bases de données PostgreSQL (sauvegarde, restauration, ...)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} check   ${CVOID}  : Test de la connexion au serveur PostgreSQL"
    echo -e "${Cjaune} dump    ${CVOID}  : Fait un dump d'une base de données"
    echo -e "${Cjaune} restore ${CVOID}  : Restauration d'une base de données"
    echo -e "${Cjaune} create  ${CVOID}  : Création d'une base de données"
    echo -e "${Cjaune} drop    ${CVOID}  : Suppréssion d'une base de données"
    echo -e "${Cjaune} sync    ${CVOID}  : Synchronisation d'une base à partir d'un serveur distant"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action CHECK
##
function olixmodule_postgres_usage_check()
{
    debug "olixmodule_postgres_usage_check ()"
    echo
    echo -e "Test de la connexion au serveur PostgreSQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}check${CVOID} ${CBLANC}[OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_postgres_usage_paramserver
    echo -en "${CBLANC} --dock= ${CVOID}"; String.pad "--dock=" 30 " "; echo " : Nom du container docker"
}


###
# Usage de l'action DUMP
##
function olixmodule_postgres_usage_dump()
{
    debug "olixmodule_postgres_usage_dump ()"
    echo
    echo -e "Faire un dump d'une base de données PostgreSQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}dump${CVOID} ${CBLANC}<base> <dumpfile> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --format=$OLIX_MODULE_POSTGRES_FORMAT ${CVOID}"; String.pad "--format=$OLIX_MODULE_POSTGRES_FORMAT" 30 " "; echo " : Format du fichier de sortie (dump)"
    olixmodule_postgres_usage_paramserver
    echo
    olixmodule_postgres_usage_listbases
}


###
# Usage de l'action RESTORE
##
function olixmodule_postgres_usage_restore()
{
    debug "olixmodule_postgres_usage_restore ()"
    echo
    echo -e "Restauration d'une base de données PostgreSQL à partir d'un fichier de dump"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}restore${CVOID} ${CBLANC}<dumpfile> <base> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_postgres_usage_paramserver
    echo
    olixmodule_postgres_usage_listbases
}


###
# Usage de l'action CREATE
##
function olixmodule_postgres_usage_create()
{
    debug "olixmodule_postgres_usage_create ()"
    echo
    echo -e "Création d'une base de données PostgreSQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}create${CVOID} ${CBLANC}<base> <owner> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_postgres_usage_paramserver
}


###
# Usage de l'action DROP
##
function olixmodule_postgres_usage_drop()
{
    debug "olixmodule_postgres_usage_drop ()"
    echo
    echo -e "Suppréssion d'une base de données PostgreSQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}drop${CVOID} ${CBLANC}base [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_postgres_usage_paramserver
    echo
    olixmodule_postgres_usage_listbases
}


###
# Usage de l'action SYNC
##
function olixmodule_postgres_usage_sync()
{
    debug "olixmodule_postgres_usage_sync ()"
    echo
    echo -e "Synchronisation d'une base à partir d'un serveur PostgreSQL distant"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}postgres ${CJAUNE}sync${CVOID} ${CBLANC}<user@host[:port]> <base_source> <base_destination>${CVOID}"
    echo
    olixmodule_postgres_usage_listbases
}


###
# Affiche les options des paramètres de connexion au serveur
##
function olixmodule_postgres_usage_paramserver()
{
    echo -en "${CBLANC} --host=$OLIX_MODULE_POSTGRES_HOST ${CVOID}"; String.pad "--host=$OLIX_MODULE_POSTGRES_HOST" 30 " "; echo " : Host du serveur PostgreSQL"
    echo -en "${CBLANC} --port=$OLIX_MODULE_POSTGRES_PORT ${CVOID}"; String.pad "--port=$OLIX_MODULE_POSTGRES_PORT" 30 " "; echo " : Port du serveur PostgreSQL"
    echo -en "${CBLANC} --user=$OLIX_MODULE_POSTGRES_USER ${CVOID}"; String.pad "--user=$OLIX_MODULE_POSTGRES_USER" 30 " "; echo " : User du serveur PostgreSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; String.pad "--pass=" 30 " "; echo " : Password du serveur PostgreSQL"
}


###
# Affiche la liste des bases disponibles
##
function olixmodule_postgres_usage_listbases()
{
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(Postgres.server.databases); do
        Print.usage.item "$I" "Base de de données $I" 15
    done
}
