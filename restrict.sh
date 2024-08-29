#!/bin/bash

PASSWORD="0x5f375a86"
START_HOUR=23
END_HOUR=12
MESSAGE="El servidor está cerrado en este momento. Es hora de dormir. Un saludo, Markus."
CURRENT_HOUR=$(date +"%H")
CONTAINER_ID=$(docker ps | awk '/minecraft_server/ {print $1}')
echo "El ID del contenedor es: $CONTAINER_ID"


activate_whitelist_and_kick_players() {
    docker exec -i <nombre_contenedor_docker> rcon-cli whitelist on
    docker exec -i <nombre_contenedor_docker> rcon-cli say "$MESSAGE"
    # Expulsar a todos los jugadores
    players=$(docker exec -i $CONTAINER_ID rcon-cli list)
    for player in $players; do
        docker exec -i $CONTAINER_ID rcon-cli kick $player "El servidor está cerrado. Es hora de dormir. Buenas noches."
    done
}

deactivate_whitelist() {
    docker exec -i $CONTAINER_ID rcon-cli whitelist off
}

request_password() {
    echo -n "Enter the master password:"
    read -s input_password
    echo
    if [ "$input_password" == "$PASSWORD" ]; then
        echo "Access granted. You have 60 seconds to enter the server. Then, sayonara!"
        deactivate_whitelist
        sleep 60
        activate_whitelist_and_kick_players
    else
        echo "Hehehe you didn't say the magic word!"
    fi
}

if [ $CURRENT_HOUR -ge $START_HOUR ] || [ $CURRENT_HOUR -lt $END_HOUR ]; then
    activate_whitelist_and_kick_players
    request_password
else
    deactivate_whitelist
fi

