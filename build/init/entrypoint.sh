#!/bin/bash
set -eu

# Default values
app_username=${app_username:-appuser}
app_user_id=${app_user_id:-1000}
app_group_id=${app_group_id:-1000}


# Parse init.ini config file
minit_run () {

  # Skip if no config found
  if [ ! -f "$MINIT_CONFIG" ]; then
    echo "MINIT: No config found in $MINIT_CONFIG"
    return 0
  fi

  # Read env vars
  if [ ! -f "$MINIT_ENV" ]; then
    echo "MINIT: No env config found in $MINIT_ENV"
  else
    echo "MINIT: Load env config ($MINIT_ENV)"
    . "$MINIT_ENV"
  fi

  # Read startup commands
  echo "MINIT: Reading $MINIT_CONFIG configuration..."
  if grep -q "^\[startup\]" "$MINIT_CONFIG" ; then
      echo "MINIT: Executing startup commands..."
      sed -n '/^\[startup\]/,/^\[/p' "$MINIT_CONFIG" | grep -v '^\[' | grep -v '^#' | grep -v '^$' | while read -r cmd; do
          if [ -n "$cmd" ]; then
              echo "MINIT: Running: $cmd"
              eval "$cmd" || echo "MINIT: WARN: Command failed: $cmd"
          fi
      done
  fi
  
  # Read services to start
  if grep -q "^\[services\]" "$MINIT_CONFIG" ; then
      echo "MINIT: Starting configured services..."
      sed -n '/^\[services\]/,/^\[/p' "$MINIT_CONFIG" | grep -v '^\[' | grep -v '^#' | grep -v '^$' | while read -r service; do
          if [ -n "$service" ]; then
              echo "MINIT: Starting service: $service"
              eval "$service &" || echo "MINIT: WARN: Service failed: $service"
          fi
      done
  fi
  
}

minit_wait () {
  local ip_list=$( ip a l | grep ' inet ' | awk '{print $2}' \
    | grep -v '127.0.0.1' | sed 's@/.*@@' \
    | sort | tr '\n' ' ')
  echo "MINIT: Container ips: $ip_list"
  echo "MINIT: Container started"
  /usr/bin/sleep infinity
  echo "MINIT: Quitting container!"
}

echo "MINIT: === Container Initialization ==="
MINIT_DIR=${MINIT_DIR:-/usr/local/init}
MINIT_ENV=${MINIT_CONFIG:-$MINIT_DIR/init_env.sh}
MINIT_CONFIG=${MINIT_CONFIG:-$MINIT_DIR/init_conf.ini}
minit_run
minit_wait

