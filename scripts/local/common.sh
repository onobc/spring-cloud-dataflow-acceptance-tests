#!/bin/sh


# ======================================= FUNCTIONS START =======================================

function stop_docker_container() {

  [ -z "$DOCKER_HOST" ] && { echo "Environment variable DOCKER_HOST must be set"; exit 1; }
  DOCKER_SERVER=$(echo $DOCKER_HOST | awk -F/ '{print $3}' | awk -F':' '{print $1}')

  if ! command_exists docker-compose; then
    echo "It appears that you don't have a docker command line executable available. Halting."
    exit 1
  fi
  echo "Shutting down $PROCESS_NAME server"
  docker-compose stop
}

function deploy_docker_container() {

  [ -z "$DOCKER_HOST" ] && { echo "Environment variable DOCKER_HOST must be set"; exit 1; }
  DOCKER_SERVER=$(echo $DOCKER_HOST | awk -F/ '{print $3}' | awk -F':' '{print $1}')
  if ! command_exists docker-compose; then
    echo "It appears that you don't have a docker command line executable available. Halting."
    exit 1
  fi

  docker-compose up -d 
  $(netcat_port $DOCKER_SERVER $SERVER_PORT)
  service_running=$?

  if [[ "$service_running" == 1 ]]; then
    echo "Could not connect to $PROCESS_NAME running on docker container at $DOCKER_SERVER:$SERVER_PORT. "
    exit 1;
  fi

  echo "$PROCESS_NAME running on $DOCKER_SERVER:$SERVER_PORT"
}

function destroy() {
  PROCESS_NAME=$1
  SERVER_PORT=$2

  $(test_port "127.0.0.1" $SERVER_PORT)
  service_running=$?

  if [[ "$service_running" == 1 ]]; then
    echo "Could not find a local $PROCESS_NAME server, trying docker."
    stop_docker_container
  fi
}

function create() {
  PROCESS_NAME=$1
  SERVER_PORT=$2
  $(test_port "127.0.0.1" $SERVER_PORT)
  service_running=$?


  if [[ "$service_running" == 1 ]]; then
    echo "Could not find a local $PROCESS_NAME server, trying docker."
    deploy_docker_container
  fi

}

# ======================================= FUNCTIONS END =======================================
