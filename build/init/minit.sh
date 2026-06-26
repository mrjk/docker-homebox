#!/bin/bash
set -eu

# Enable DEBUG logs
export MINIT_DEBUG=${MINIT_DEBUG:-false}
# Enable shell script trace
export MINIT_TRACE=${MINIT_TRACE:-false}

# Main config directory
export MINIT_DIR=${MINIT_DIR:-/usr/local/init}

# Internal variables
export MINIT_DEFAULT_DIR=${MINIT_DIR}/defaults
export MINIT_OVERRIDE_DIR=${MINIT_DIR}/overrides


# Helper functions
# ==================================

log ()
{

  local level=${1:-DEBUG}
  if [[ "$level" == 'DEBUG' ]] && [[ "$MINIT_DEBUG" == false ]]; then
    return 0
  fi

  shift 1
  local msg=${@:-}
  >&2 printf '%6s|minit: %s\n' "$level" "$msg"
}

die () {
  local rc=${1:-1}
  shift 1
  local msg=${@:-}
  log FATAL "$msg"
  exit $rc
}

title ()
{
  log DEBUG
  log DEBUG "$@"
  log DEBUG "=============================="
}


# Config Helpers functions
# ==================================

find_files () {
    local dirs="$1"
    local globs="$2"

    IFS=':' read -ra dir_list  <<< "$dirs"
    IFS=':' read -ra glob_list <<< "$globs"

    local results=()

    for dir in "${dir_list[@]}"; do
        for glob in "${glob_list[@]}"; do
            while IFS= read -r match; do
                results+=("$match")
            done < <(find "$dir" -maxdepth 1 -name "$glob" -type f 2>/dev/null)
        done
    done

    printf '%s\n' "${results[@]}" | awk -F'/' '{print $NF, $0}' | sort -f -k1 | cut -d' ' -f2-
}

find_configs () {
    local dirs="$1"
    local globs="$2"

    IFS=':' read -ra dir_list  <<< "$dirs"
    IFS=':' read -ra glob_list <<< "$globs"

    declare -A seen

    for dir in "${dir_list[@]}"; do
        for glob in "${glob_list[@]}"; do
            while IFS= read -r match; do
                local basename="${match##*/}"
                seen["$basename"]="$match"
            done < <(find "$dir" -maxdepth 1 -name "$glob" -type f 2>/dev/null)
        done
    done

    for basename in "${!seen[@]}"; do
        printf '%s\n' "${seen[$basename]}"
    done | awk -F'/' '{print $NF "\t" $0}' | sort -f -k1 | cut -f2-
}


# Config Helpers functions
# ==================================

minit_run () {

  log INFO "Using config in: $MINIT_DIR"

  # Manage environment files
  # ========================
  title "Loading env files"
  mapfile -t files < <(find_configs "$MINIT_DEFAULT_DIR/env:$MINIT_OVERRIDE_DIR/env" "*env:*.sh")

  for file in "${files[@]}"; do
      log INFO "Sourcing environment: $file"
      source "$file"
  done

  # Manage helpers scripts
  # ========================
  export PATH=$MINIT_OVERRIDE_DIR/scripts:$MINIT_DEFAULT_DIR/scripts:$PATH

  # Manage init scripts
  # ========================
  title  "Loading init scripts"
  mapfile -t files < <(find_configs "$MINIT_DEFAULT_DIR/init:$MINIT_OVERRIDE_DIR/init" "*.bash:*.sh")

  for file in "${files[@]}"; do
      log INFO "Executing script: $file"
      "$file"
  done

  # Start standard init system
  # ========================
  if command -v supervisord >&/dev/null; then
    minit_pid1_supervisor
  else
    minit_pid1_sleep
  fi
  log INFO "Quitting container!"
}


minit_info () {
  log DEBUG "Container hostname: $(cat /etc/hostname)"
  local ip_raw=
  if command -v ip >&/dev/null; then
    ip_raw=$(ip a l)
  elif command -v ifconfig >&/dev/null; then
    ip_raw=$(ifconfig)
  else
    log DEBUG "No networking tool available in container"
    return 0
  fi
  local ip_list=$( echo "$ip_raw" | grep ' inet ' | awk '{print $2}' \
    | grep -v '127.0.0.1' | sed 's@/.*@@' \
    | sort | tr '\n' ' ')
  log INFO "Container ips: $ip_list"
}

minit_pid1_supervisor () {
  # Manage supervisord config
  # ========================
  title "Loading services files (supervisor)"
  mapfile -t files < <(find_configs "$MINIT_DEFAULT_DIR/services:$MINIT_OVERRIDE_DIR/services" "*.conf")

  # Generate supervisord config
  local supervisor_conf=/etc/supervisor.conf
  #cp /usr/local/init/supervisord.conf "$supervisor_conf"
  cat > "$supervisor_conf" <<EOF
[supervisord]
nodaemon=true
logfile=/dev/null
logfile_maxbytes=0
pidfile=/var/run/supervisord.pid
EOF

  if [[ "$(id -u)" -eq 0 ]]; then
    log INFO "Using supervisor as root user"
    echo "user=root" >> "$supervisor_conf"
  fi

  # Generate includes
  echo "" >> "$supervisor_conf"
  echo "[include]" >> "$supervisor_conf"
  echo "files = ${files[@]}" >> "$supervisor_conf"
  for file in "${files[@]}"; do
      if grep -q ' ' <<< "$file" ; then
        die 1 "Supervisor does not support spaces in filenames: $file"
      fi
      log DEBUG "Using supervisor config: $file"
  done
  log "INFO" "Supervisord configuration generated in: $supervisor_conf"

  # Start supervisord
  minit_info
  title "Starting supervisord"
  log "INFO" "Starting supervisord ..."
  exec supervisord -c "$supervisor_conf"
  # exec supervisord -j /tmp/supervisord.pid -c "$supervisor_conf"
}

minit_pid1_sleep () {
  minit_info
  log DEBUG "Container started (sleep infinity)"
  exec /usr/bin/sleep infinity
}

# Startup management
if [ $# -eq 0 ]; then
  log INFO "Container Initialization"
  minit_run
else
  log DEBUG "Executing command: $@"
  log INFO "Execute default entrypoint with: $0"
  exec "$@"
fi

