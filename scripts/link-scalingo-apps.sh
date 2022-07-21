#!/bin/bash

set -euo pipefail

scalingo apps

: ${SUFFIX?}

TIMEOUT=30

function log() {
  local msg=$1

  >&2 echo "$msg"
}

function get_app_name() {
  local service=$1
  echo cdb-$service$SUFFIX
}

function wait_for_service_ready() {
  local service=$1

  local appname=$(get_app_name $service)

  log "* Waiting for $appname to be ready..."

  local waited=0
  local status

  while [[ $waited -lt $TIMEOUT ]]; do
    status=$(scalingo -a $appname apps-info|awk '/Status/{print $4}')
    log "  - $appname is now: $status"
    if [[ "$status" == stopped || "$status" == running ]]; then
      return
    fi
    sleep 5
    waited=$((waited + 5))
  done

  log "ERROR: $appname was not stopped or running after $TIMEOUT seconds"
  exit 1
}

function wait_for_apps_ready() {
  wait_for_service_ready app
  wait_for_service_ready backend
  wait_for_service_ready hasura
}

function get_database_url() {
  scalingo -a $(get_app_name hasura) env-get SCALINGO_POSTGRESQL_URL
}

function compute_urls() {
  APP_URL=https://$(get_app_name app).osc-fr1.scalingo.io
  BACKEND_URL=https://$(get_app_name backend).osc-fr1.scalingo.io
  GRAPHQL_URL=https://$(get_app_name hasura).osc-fr1.scalingo.io/v1/graphql
  DATABASE_URL=$(get_database_url)
}

function env_set() {
  local service=$1
  local var=$2
  local value=$3

  local appname=$(get_app_name $service)

  log "* Setting $var on $appname"

  # Redirect to /dev/null to avoid printing secrets to the logs
  scalingo -a $appname env-set "$var=$value" >/dev/null 2>&1
}

function set_backend_env() {
  env_set backend DATABASE_URL "$DATABASE_URL"
  env_set backend APP_URL "$APP_URL"
}

function set_hasura_env() {
  env_set hasura ACTION_BASE_URL "$APP_URL/actions"
}

function set_app_env() {
  env_set app APP_URL "$APP_URL"
  env_set app BACKEND_API_URL "$BACKEND_URL"
  env_set app GRAPHQL_API_URL "$GRAPHQL_URL"
}

function stop_apps() {
  # To avoid overloading PG connections it's safer to stop apps
  # before restarting them.
  log "* Stopping apps..."

  # The Scalingo API returns an error when trying to stop an
  # app that is already stopped, we'll ignore all errors and$
  # hope not to miss anything important.
  scalingo -a $(get_app_name hasura) scale web:0 || true
  scalingo -a $(get_app_name backend) scale web:0 || true
  scalingo -a $(get_app_name app) scale web:0 || true
}

function start_apps() {
  log "* Starting apps..."

  scalingo -a $(get_app_name hasura) scale web:1:M
  scalingo -a $(get_app_name backend) scale web:1:S
  scalingo -a $(get_app_name app) scale web:1:S
}

wait_for_apps_ready

stop_apps

compute_urls

set_backend_env
set_hasura_env
set_app_env

start_apps
