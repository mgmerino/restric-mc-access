#!/bin/bash

if [ ! -f .env ]
then
  export $(cat `dirname $0`/../.env | xargs)
fi

source `dirname $0`/functions.sh

main() {
  check_jq_installed || exit 1

  local START_HOUR=23
  local END_HOUR=10
  local BAN_MESSAGE="El servidor está cerrado en este momento. Es hora de descansar."
  local UNBAN_MESSAGE="El servidor está abierto nuevamente. Puedes volver a entrar."
  local CURRENT_HOUR=$(get_current_hour)
  local CONTAINER_NAME=$(get_container_name)

  if [ -z "$CONTAINER_NAME" ]; then
    echo "$(date) No minecraft-server container found. Exiting..."
    exit 1
  fi

  echo "Found a minecraft container, name: $CONTAINER_NAME"

  local ban_command="docker exec -i $CONTAINER_NAME rcon-cli ban"
  local unban_command="docker exec -i $CONTAINER_NAME rcon-cli pardon"

  manage_server_access "$START_HOUR" "$END_HOUR" "$CURRENT_HOUR" "$CONTAINER_NAME" "$BAN_MESSAGE" "$UNBAN_MESSAGE" "$ban_command" "$unban_command"
}

main
