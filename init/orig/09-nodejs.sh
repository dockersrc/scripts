#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -o pipefail -x$DEBUGGER_OPTIONS || set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export PATH="/usr/local/etc/docker/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run trap command on exit
trap 'retVal=$?;[ "$SERVICE_IS_RUNNING" != "true" ] && [ -f "/run/init.d/$EXEC_CMD_BIN.pid" ] && rm -Rf "/run/init.d/$EXEC_CMD_BIN.pid";exit $retVal' SIGINT SIGTERM EXIT
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import the functions file
if [ -f "/usr/local/etc/docker/functions/entrypoint.sh" ]; then
  . "/usr/local/etc/docker/functions/entrypoint.sh"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables
for set_env in "/root/env.sh" "/usr/local/etc/docker/env"/*.sh "/config/env"/*.sh; do
  [ -f "$set_env" ] && . "$set_env"
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom functions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute command variables
WORKDIR=""                   # set working directory
SERVICE_UID="0"              # set the user id
SERVICE_USER="root"          # execute command as another user
SERVICE_PORT="${PORT:-3000}" # port which service is listening on
EXEC_CMD_BIN="nodemon"       # command to execute
EXEC_CMD_ARGS=""             # command arguments
PRE_EXEC_MESSAGE=""          # Show message before execute
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Other variables that are needed
NODE_MANAGER="${NODE_MANAGER:-system}"
NODE_VERSION="${NODE_VERSION:-12}"
export NVM_DIR="$HOME/.nvm"
export FNM_DIR="$HOME/.fnm"
export FNM_LOGLEVEL="error"
export FNM_INTERACTIVE_CLI="false"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
[ -f "/app/.node_version" ] && NODE_VERSION="$(</app/.node_version)"
[ -f "/app/.env" ] && . "/app/.env"
[ -f "/root/.bashrc" ] && . /root/.bashrc
export NODE_VERSION NODE_MANAGER
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -z "$(type -P node)" ] && [ -n "$(type -P apt)" ]; then
  echo "Installing default nodejs package - this may take a minute...."
  apt install -yy -q nodejs npm yarn unzip &>/dev/null
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# use this function to update config files - IE: change port
__update_conf_files() {
  [ -d "/app" ] || mkdir -p /app
  if [ -z "$(type fnm 2>/dev/null)" ] && [ "$NODE_MANAGER" = "fnm" ]; then
    echo "Initializing fnm..."
    grep -qs 'FNM export' "/config/env/node.sh" && BASHRC="false"
    curl -q -LSsf "https://fnm.vercel.app/install" -o "/tmp/node_init.bash" && chmod 755 "/tmp/node_init.bash"
    bash "/tmp/node_init.bash" --install-dir "/usr/local/bin" --force-install --skip-shell &>/dev/null
    if [ "$BASHRC" != "false" ]; then
      cat <<EOF >>"/config/env/node.sh"
# FNM export 
[ -n "$(type fnm 2>/dev/null)" ] && eval "\$(fnm env --shell bash)"
EOF
    fi
  elif [ -z "$(type nvm 2>/dev/null)" ] && [ "$NODE_MANAGER" = "nvm" ]; then
    echo "Initializing nvm..."
    grep -qs 'NVM' "/config/env/node.sh" && BASHRC="false"
    curl -q -LSsf "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" -o "/tmp/node_init.bash" && chmod 755 "/tmp/node_init.bash"
    bash "/tmp/node_init.bash" &>/dev/null
    if [ "$BASHRC" != "false" ]; then
      cat <<EOF >>"/config/env/node.sh"
# NVM export
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && . "\$NVM_DIR/bash_completion"
EOF
    fi
  else
    echo "Initializing nodejs..."
  fi
  [ -d "$HOME.local/state/" ] && rm -Rf "$HOME.local/state"
  [ -f "/tmp/node_init.bash" ] && rm -Rf "/tmp/node_init.bash"

  return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# use this function to setup ssl support
__update_ssl_conf() {

  return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# function to run before executing
__pre_execute() {
  if [ "$NODE_MANAGER" = "fnm" ]; then
    echo "Installing node $NODE_VERSION from fnm"
    [ -f "/config/env/node.sh" ] && . /config/env/node.sh
    fnm install $NODE_VERSION &>/dev/null
    fnm default $NODE_VERSION &>/dev/null
    fnm use $NODE_VERSION &>/dev/null
    NODE_VERSION_INST="$(node --version 2>/dev/null)"
  elif [ "$NODE_MANAGER" = "nvm" ]; then
    echo "Installing node $NODE_VERSION from nvm"
    [ -f "/config/env/node.sh" ] && . /config/env/node.sh
    nvm install $NODE_VERSION &>/dev/null
    nvm alias default $NODE_VERSION &>/dev/null
    nvm use $NODE_VERSION &>/dev/null
    NODE_VERSION_INST="$(node --version 2>/dev/null)"
  else
    echo "Using nodejs from distro"
    NODE_VERSION_INST="$(node --version 2>/dev/null)"
  fi
  #
  package_file="$(find "/app" -name 'package.json' | head -n1 | grep '^' || echo '')"
  if [ -f "$package_file" ]; then
    if [ -x "/app/start.sh" ]; then
      EXEC_CMD_BIN="/app/start.sh"
    elif cat "$package_file" 2>/dev/null | jq -r '.scripts.start:dev' 2>/dev/null | grep -v 'null'; then
      EXEC_CMD_ARGS="--exec npm run start:dev"
    elif cat "$package_file" 2>/dev/null | jq -r '.scripts.dev' 2>/dev/null | grep -v 'null'; then
      EXEC_CMD_ARGS="--exec npm run dev"
    elif cat "$package_file" 2>/dev/null | jq -r '.scripts.start' 2>/dev/null | grep -v 'null'; then
      EXEC_CMD_ARGS="--exec npm run start"
    elif [ -f "/app/index.js" ]; then
      EXEC_CMD_ARGS="/app/index.js"
    elif [ -f "/app/app.js" ]; then
      EXEC_CMD_ARGS="/app/app.js"
    elif [ -f "/app/server.js" ]; then
      EXEC_CMD_ARGS="/app/server.js"
    elif [ -f "/app/server/index.js" ]; then
      EXEC_CMD_ARGS="/app/server/server/index.js"
    elif [ -f "/app/client/index.js" ]; then
      EXEC_CMD_ARGS="/app/client/server/index.js"
    fi
  else
    EXEC_CMD_ARGS="/app/index.js"
    [ -n "$(type -P npm)" ] && npm init -y &>/dev/null && npm i -D nodemon &>/dev/null && touch /app/index.js || { echo "npm not found" && exit 10; }
  fi
  [ -n "$NODE_VERSION_INST" ] && echo "node is set to use version: $NODE_VERSION_INST" || { echo "Can not find nodejs" && exit 10; }
  npm i -D &>/dev/null && npm i -g nodemon &>/dev/null

  return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# script to start server
__run_start_script() {
  local workdir="${WORKDIR:-$HOME}"
  local cmd="$EXEC_CMD_BIN $EXEC_CMD_ARGS"
  local user="${SERVICE_USER:-root}"
  local lc_type="${LC_ALL:-${LC_CTYPE:-$LANG}}"
  local home="${workdir//\/root/\/home\/docker}"
  local path="/usr/local/bin:/usr/bin:/bin:/usr/sbin"
  case "$1" in
  check) shift 1 && __pgrep $EXEC_CMD_BIN || return 5 ;;
  *) su_cmd env -i PWD="$home" HOME="$home" LC_CTYPE="$lc_type" PATH="$path" USER="$user" sh -c "$cmd" || return 10 ;;
  esac
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# process check functions
__pcheck() { [ -n "$(type -P pgrep 2>/dev/null)" ] && pgrep -x "$1" &>/dev/null && return 0 || return 10; }
__pgrep() { __pcheck "${1:-EXEC_CMD_BIN}" || __ps aux 2>/dev/null | grep -Fw " ${1:-$EXEC_CMD_BIN}" | grep -qv ' grep' | grep '^' && return 0 || return 10; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Allow ENV_ variable
[ -f "/config/env/$EXEC_CMD_BIN.sh" ] && "/config/env/$EXEC_CMD_BIN.sh" # Import env file
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
WORKDIR="${ENV_WORKDIR:-$WORKDIR}"                            # change to directory
SERVICE_USER="${ENV_SERVICE_USER:-$SERVICE_USER}"             # execute command as another user
SERVICE_UID="${ENV_SERVICE_UID:-$SERVICE_UID}"                # set the user id
SERVICE_PORT="${ENV_SERVICE_PORT:-$SERVICE_PORT}"             # port which service is listening on
EXEC_CMD_BIN="${ENV_EXEC_CMD_BIN:-$EXEC_CMD_BIN}"             # command to execute
EXEC_CMD_ARGS="${ENV_EXEC_CMD_ARGS:-$EXEC_CMD_ARGS}"          # command arguments
PRE_EXEC_MESSAGE="${ENV_PRE_EXEC_MESSAGE:-$PRE_EXEC_MESSAGE}" # Show message before execute
SERVICE_EXIT_CODE=0                                           # default exit code
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
printf '%s\n' "# - - - Attempting to start $EXEC_CMD_BIN - - - #"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ensure the command exists
if [ ! -f "$(type -P "$EXEC_CMD_BIN")" ] && [ -z "$EXEC_CMD_BIN" ]; then
  echo "$EXEC_CMD_BIN is not a valid command"
  exit 2
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check if process is already running
if __pgrep "$EXEC_CMD_BIN"; then
  SERVICE_IS_RUNNING="true"
  echo "$EXEC_CMD_BIN is running"
  exit 0
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# show message if env exists
if [ -n "$EXEC_CMD_BIN" ]; then
  [ -n "$SERVICE_USER" ] && echo "Setting up service to run as $SERVICE_USER"
  [ -n "$SERVICE_PORT" ] && echo "$EXEC_CMD_BIN will be running on $SERVICE_PORT"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Change to working directory
[ -n "$WORKDIR" ] && mkdir -p "$WORKDIR" && __cd "$WORKDIR" && echo "Changed to $PWD"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initialize ssl
__update_ssl_conf
__update_ssl_certs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Updating config files
__update_conf_files
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run the pre execute commands
[ -n "$PRE_EXEC_MESSAGE" ] && echo "$PRE_EXEC_MESSAGE"
__pre_execute
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
WORKDIR="${WORKDIR:-}"
if [ "$SERVICE_USER" = "root" ] || [ -z "$SERVICE_USER" ]; then
  su_cmd() { eval "$@" || return 1; }
elif [ "$(builtin type -P gosu)" ]; then
  su_cmd() { gosu $SERVICE_USER "$@" || return 1; }
elif [ "$(builtin type -P runuser)" ]; then
  su_cmd() { runuser -u $SERVICE_USER "$@" || return 1; }
elif [ "$(builtin type -P sudo)" ]; then
  su_cmd() { sudo -u $SERVICE_USER "$@" || return 1; }
elif [ "$(builtin type -P su)" ]; then
  su_cmd() { su -s /bin/sh - $SERVICE_USER -c "$@" || return 1; }
else
  echo "Can not switch to $SERVICE_USER: attempting to run as root"
  su_cmd() { eval "$@" || return 1; }
fi
if [ -n "$WORKDIR" ] && [ "${SERVICE_USER:-$USER}" != "root" ]; then
  echo "Fixing file permissions"
  su_cmd chown -Rf $SERVICE_USER $WORKDIR $etc_dir $var_dir $log_dir
fi
if __pgrep $EXEC_CMD_BIN && [ -f "/run/init.d/$EXEC_CMD_BIN.pid" ]; then
  SERVICE_EXIT_CODE=1
  echo "$EXEC_CMD_BIN" is already running
else
  echo "Starting service: $EXEC_CMD_BIN $EXEC_CMD_ARGS"
  su_cmd touch /run/init.d/$EXEC_CMD_BIN.pid
  __run_start_script "$@" |& tee -a "/data/logs/entrypoint.log"
  if [ "$?" -ne 0 ]; then
    echo "Failed to execute: $EXEC_CMD_BIN $EXEC_CMD_ARGS"
    SERVICE_EXIT_CODE=10 SERVICE_IS_RUNNING="false"
    su_cmd rm -Rf "/run/init.d/$EXEC_CMD_BIN.pid"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $SERVICE_EXIT_CODE
