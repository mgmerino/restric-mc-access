#!/usr/bin/env bats
setup() {
  source './src/functions.sh'

  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  

  players_connected="player1
  player2"
  allowed_players="player1
  player2"
  banned_players="player1
  player2
  player3"

  mock_docker_ban() {
    echo "docker command: banning $1"
  }

  mock_docker_unban() {
    echo "docker command: unbanning $1"
  }

  get_banned_players() {
    echo "${banned_players}"
  }

  get_allowed_players() {
    echo "$allowed_players"
  }

  get_players_connected() {
    echo "$players_connected"
  }

  get_container_name() {
    echo "minecraft-server"
  }

  get_current_hour() {
    echo 23
  }
}

@test "Should ban all connected players" {
  ban_message="El servidor está cerrado en este momento. Es hora de descansar."

  run ban_all_players "$players_connected" "$ban_message" mock_docker_ban 

  assert_output --partial "docker command: banning player1"
}

@test "Should unban allowed players" {
  run unban_players "$allowed_players" "$banned_players" mock_docker_unban
  
  assert_output --partial "docker command: unbanning player1"
}

@test "Should manage server access and ban players based on time" {
  start_hour=23
  end_hour=10
  ban_message="El servidor está cerrado en este momento. Es hora de descansar."
  unban_message="El servidor está abierto nuevamente. Puedes volver a entrar."

  run manage_server_access "$start_hour" "$end_hour" $(get_current_hour) $(get_container_name) "$ban_message" "$unban_message" mock_docker_ban mock_docker_unban
  
  assert_output --partial "player2 ha sido baneado"
}

@test "Should manage server access and unban players based on time" {
  start_hour=23
  end_hour=10
  allowed_hour=13
  ban_message="El servidor está cerrado en este momento. Es hora de descansar."
  unban_message="El servidor está abierto nuevamente. Puedes volver a entrar."

  run manage_server_access "$start_hour" "$end_hour" $allowed_hour $(get_container_name) "$ban_message" "$unban_message" mock_docker_ban mock_docker_unban
    
  assert_output --partial "player2 ha sido desbaneado"
}

@test "Should not ban players if there are no players connected" {
  players_connected=""
  start_hour=23
  end_hour=10
  ban_message="El servidor está cerrado en este momento. Es hora de descansar."
  unban_message="El servidor está abierto nuevamente. Puedes volver a entrar."

  run manage_server_access "$start_hour" "$end_hour" $(get_current_hour) "$ban_message" "$unban_message" mock_docker_ban mock_docker_unban

  expected_output="No hay jugadores conectados al servidor."
    
  assert_output --partial "$expected_output"
}
