###
# Test de la connexion au serveur PostgreSQL
# ==============================================================================
# @package olixsh
# @module postgres
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Traitement
##
if [[ -z ${OLIX_MODULE_POSTGRES_DOCK} ]]; then

    # Mode serveur
    if [[ -z $OLIX_MODULE_POSTGRES_HOST ]]; then
        echo -e "Test de connexion avec ${Ccyan}${OLIX_MODULE_POSTGRES_USER} (socket UNIX)${CVOID}"
    else
        echo -e "Test de connexion avec ${Ccyan}${OLIX_MODULE_POSTGRES_USER}@${OLIX_MODULE_POSTGRES_HOST}:${OLIX_MODULE_POSTGRES_PORT}${CVOID}"
    fi

    Postgres.server.check
    [[ $? -ne 0 ]] && critical "Echec de connexion au serveur PostgreSQL"

    psql --version

else

    # Mode docker
    echo -e "Test de connexion avec le containeur ${Ccyan}${OLIX_MODULE_POSTGRES_DOCK}${CVOID}"

    Postgres.docker.check "${OLIX_MODULE_POSTGRES_DOCK}"
    [[ $? -ne 0 ]] && critical "Echec de connexion au serveur PostgreSQL"

    docker exec -i ${OLIX_MODULE_POSTGRES_DOCK} psql --version

fi


###
# FIN
##
echo -e "${CVERT}Connexion au serveur PostgreSQL réussi${CVOID}"
