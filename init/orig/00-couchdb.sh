#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -o pipefail -x$DEBUGGER_OPTIONS || set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export PATH="/opt/couchdb/bin:/usr/local/etc/docker/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
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
__curl() { curl -q -LSsf --user $user_name:$user_pass "$@" 2>/dev/null || return 10; }
__curl_database() { curl -q -LSsf -X PUT "http://$user_name:$user_pass@127.0.0.1:$SERVICE_PORT/$1" 2>/dev/null; }
__curl_users() { __curl -X PUT "http://localhost:$SERVICE_PORT/_users/org.couchdb.user:$1" -H "Accept: application/json" -H "Content-Type: application/json" -d '{"name": "'$1'", "password": "'$2'", "roles": [], "type": "user"}' || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute command variables
WORKDIR=""             # set working directory
SERVICE_UID="0"        # set the user id
SERVICE_USER="couchdb" # execute command as another user
SERVICE_PORT="5984"    # port which service is listening on
EXEC_CMD_BIN="couchdb" # command to execute
EXEC_CMD_ARGS=""       # command arguments
PRE_EXEC_MESSAGE=""    # Show message before execute
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Other variables that are needed
etc_dir="/opt/couchdb"
conf_dir="/config/couchdb"
db_dir="/data/db/couchdb"
user_pass="${COUCHDB_PASSWORD:-$SET_RANDOM_PASS}"
user_name="${COUCHDB_USER:-root}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# use this function to update config files - IE: change port
__update_conf_files() {
  mkdir -p "/data/db" "/run/init.d"
  [ -d "$db_dir" ] && [ -L "$etc_dir/data" ] && return
  [ -L "$etc_dir/data" ] || [ -d "$db_dir" ] || { [ -d "$etc_dir/data" ] && mv -f "$etc_dir/data" "$db_dir"; }
  [ -e "$etc_dir/data" ] && rm -Rf "$etc_dir/data"
  ln -sf "$db_dir" "$etc_dir/data" 2>/dev/null
  touch "$etc_dir/etc/local.d/docker.ini" 2>/dev/null
  chown -Rf $SERVICE_USER:$SERVICE_USER "$db_dir" "$etc_dir" 2>/dev/null
  [ -n "$user_name" ] && echo "couchdb user name is: $user_name"
  [ -n "$user_pass" ] && echo "couchdb user pass is: $user_pass"

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
  (
    sleep 20
    if __curl http://127.0.0.1:$SERVICE_PORT/_users | grep -qv 'db_name":"_users'; then
      echo "Creating the _users databases"
      __curl -X PUT "http://127.0.0.1:$SERVICE_PORT/_users" | grep -q '200' && echo "Created database _users"
      sleep 1
    fi
    if __curl http://127.0.0.1:$SERVICE_PORT/_replicator | grep -qv 'db_name":"_replicator'; then
      echo "Creating the _replicator databases"
      __curl -X PUT "http://127.0.0.1:$SERVICE_PORT/_replicator" | grep -q '200' && echo "Created database _replicator"
      sleep 1
    fi
    if __curl http://127.0.0.1:$SERVICE_PORT/_global_changes | grep -v 'db_name":"_global_changes'; then
      echo "Creating the _global_changes databases"
      __curl -X PUT "http://127.0.0.1:$SERVICE_PORT/_global_changes" | grep -q '200' && echo "Created database _global_changes"
      sleep 1
    fi
    if [ -n "$CREATE_USER" ]; then
      __curl_users "$user_name" "$user_pass"
    fi
    echo ""
  ) &

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
  local path="/opt/couchdb/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin"
  case "$1" in
  check) shift 1 && __pgrep $EXEC_CMD_BIN || return 5 ;;
  *)
    set -e
    if [ "$(id -u)" = '0' ]; then
      find $etc_dir \! \( -user couchdb -group couchdb \) -exec chown -f $SERVICE_USER:$SERVICE_USER '{}' +
      find $etc_dir/data -type d ! -perm 0755 -exec chmod -f 0755 '{}' +
      find $etc_dir/data -type f ! -perm 0644 -exec chmod -f 0644 '{}' +
      find $etc_dir/etc -type d ! -perm 0755 -exec chmod -f 0755 '{}' +
      find $etc_dir/etc -type f ! -perm 0644 -exec chmod -f 0644 '{}' +
    fi
    if [ -n "$NODENAME" ] && ! grep "couchdb@" $etc_dir/etc/vm.args; then
      echo "-name couchdb@$NODENAME" >>$etc_dir/etc/vm.args
    fi
    if [ -n "$user_name" ] && [ -n "$user_pass" ]; then
      if ! grep -sPzoqr "\[admins\]\n$user_name =" $etc_dir/etc/local.d/*.ini $etc_dir/etc/local.ini; then
        printf "\n[admins]\n%s = %s\n" "$user_name" "$user_pass" >>$etc_dir/etc/local.d/docker.ini
      fi
    fi
    if [ -n "$COUCHDB_SECRET" ]; then
      if ! grep -sPzoqr "\[chttpd_auth\]\nsecret =" $etc_dir/etc/local.d/*.ini $etc_dir/etc/local.ini; then
        printf "\n[chttpd_auth]\nsecret = %s\n" "$COUCHDB_SECRET" >>$etc_dir/etc/local.d/docker.ini
      fi
    fi
    if [ -n "$COUCHDB_ERLANG_COOKIE" ]; then
      cookieFile="$etc_dir/.erlang.cookie"
      if [ -e "$cookieFile" ]; then
        if [ "$(cat "$cookieFile" 2>/dev/null)" != "$COUCHDB_ERLANG_COOKIE" ]; then
          echo >&2
          echo >&2 "warning: $cookieFile contents do not match COUCHDB_ERLANG_COOKIE"
          echo >&2
        fi
      else
        echo "$COUCHDB_ERLANG_COOKIE" >"$cookieFile"
      fi
      chown $SERVICE_USER:$SERVICE_USER "$cookieFile"
      chmod 600 "$cookieFile"
    fi
    if [ "$(id -u)" = '0' ]; then
      chown -f $SERVICE_USER:$SERVICE_USER $etc_dir/etc/local.d/docker.ini || true
    fi
    su_cmd env -i PWD="$home" HOME="$home" LC_CTYPE="$lc_type" PATH="$path" USER="$user" sh -c "$cmd" || return 10
    ;;
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
