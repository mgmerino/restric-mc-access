check_jq_installed() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. You must install it for this script to work." >&2
    return 1
  fi
}

get_current_hour() {
  echo "$(date +"%H")"
}

get_container_name() {
  docker ps | awk '/minecraft-server/ {print $NF}'
}

get_players_connected() {
  local container_name="$1"
  docker exec -i "$container_name" rcon-cli list | awk -F': ' '{print $2}'
}

get_banned_players() {
  cat $BANNED_PLAYERS_FILE | jq -r '.[].name'
}

get_allowed_players() {
  cat $ALLOWED_PLAYERS_FILE
}

ban_all_players() {
  local players_connected="$1"
  local ban_message="$2"
  local ban_command="$3"
  if [ -z "$players_connected" ]; then
    echo "$(date) No hay jugadores conectados al servidor."
    return 1
  fi

  while IFS= read -r player; do
    $ban_command "$player" "$ban_message"
    echo "$(date) $player ha sido baneado. $ban_message"
  done <<< "$players_connected"
}

unban_players() {
  local allowed_players="$1"
  local banned_players="$2"
  local unban_command="$3"

  while IFS= read -r player; do
    if [ -z "$player" ]; then
      continue
    fi
    if exists_in_list "$banned_players" " " $player; then
      $unban_command "$player"
      echo "$(date) $player ha sido desbaneado."
    else
      echo "$(date) $player no está baneado."
    fi
  done <<< "$allowed_players"
}

exists_in_list() {
  local list=$1
  local delimiter=$2
  local value=$3
  echo $list | tr "$delimiter" '\n' | grep -F -q -x "$value"
}

manage_server_access() {
  local start_hour="$1"
  local end_hour="$2"
  local current_hour="$3"
  local container_name="$4"
  local ban_message="$5"
  local unban_message="$6"
  local ban_command="$7"
  local unban_command="$8"
  
  local players_connected=$(get_players_connected "$container_name")
  local banned_players=$(get_banned_players)
  local allowed_players=$(get_allowed_players)

  if [ "$current_hour" -ge "$start_hour" ] || [ "$current_hour" -lt "$end_hour" ]; then
    ban_all_players "$players_connected" "$ban_message" "$ban_command"
  else
    unban_players "$allowed_players" "$banned_players" "$unban_command"
  fi
}