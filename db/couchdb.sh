#!/usr/bin/env sh
export PATH="/opt/couchdb/bin:$PATH"
RUN_AS="${SERVICE_USER:-couchdb}"
COUCHDB_USER="${DATABASE_USER_ROOT:-root}"
COUCHDB_PASSWORD=${DATABASE_PASS_ROOT:-couchdb_password}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__exec_command() {
  exitCode=0
  cmd="${*:-bash -l}"
  echo "${exec_message:-Executing command: $cmd}"
  $cmd || exitCode=1
  [ "$exitCode" = 0 ] || exitCode=10
  return ${exitCode:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__curl() { curl -q -LSsf --user $COUCHDB_USER:$COUCHDB_PASSWORD "$@" || return 1; }
__curl_database() { curl -q -LSsf -X PUT "http://$COUCHDB_USER:$COUCHDB_PASSWORD@127.0.0.1:5984/$1" || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__curl_users() {
  __curl -X PUT "http://localhost:5984/_users/org.couchdb.user:$1" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{"name": "'$1'", "password": "'$2'", "roles": ['$4'], "type": "'${3:-user}'"}'
  return $?
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -z "$DATA_DIR_INITIALIZED" ] && [ -f "/data/.docker_has_run" ] && DATA_DIR_INITIALIZED="true" || DATA_DIR_INITIALIZED="false"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create user if needed
if ! grep -q "$RUN_AS" /etc/passwd; then
  groupadd -g 5984 -r $RUN_AS && useradd -u 5984 -d /opt/$RUN_AS -g $RUN_AS $RUN_AS
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d "/data/couchdb" ] || mv -f "/opt/couchdb/data" "/data/couchdb"
[ -d "/opt/couchdb/data" ] && rm -Rf "/opt/couchdb/data"
ln -sf "/data/couchdb" "/opt/couchdb/data" 2>/dev/null
touch "/opt/couchdb/etc/local.d/docker.ini" 2>/dev/null
chown -Rf $RUN_AS:$RUN_AS "/data/couchdb" "/opt/couchdb" 2>/dev/null
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
db)
  shift 1
  case "$1" in
  create)
    shift 1
    __curl_database "$1"
    exit $?
    ;;
  update)
    shift 1
    __curl_database "$1"
    exit $?
    ;;
  *)
    echo "Usage: db [create,update] name"
    exit 1
    ;;
  esac
  ;;

user)
  shift 1
  case "$1" in
  create)
    shift 1
    __curl_users "$1" "${2:-password}"
    exit $?
    ;;
  update)
    shift 1
    __curl_users "$1" "${2:-password}"
    exit $?
    ;;
  *)
    echo "Usage: user [create,update] username password type roles"
    ;;
  esac
  ;;

init)
  shift 1
  if [ "$DATA_DIR_INITIALIZED" = "false" ]; then
    {
      sleep 60
      echo "Creating the default databases"
      __curl -X PUT "http://127.0.0.1:5984/_users" 2>/dev/null >/dev/null &&
        echo "Created database _users"
      __curl -X PUT "http://127.0.0.1:5984/_replicator" 2>/dev/null >/dev/null &&
        echo "Created database _replicator"
      __curl -X PUT "http://127.0.0.1:5984/_global_changes" 2>/dev/null >/dev/null &&
        echo "Created database _global_changes"
      echo ""
    } >"/dev/stdout" &
  fi
  exit $?
  ;;

*)
  if [ "$(id -u)" = '0' ]; then
    find /opt/couchdb \! \( -user $RUN_AS -group $RUN_AS \) -exec chown -f $RUN_AS:$RUN_AS '{}' +
    find /opt/couchdb/data -type d ! -perm 0755 -exec chmod -f 0755 '{}' +
    find /opt/couchdb/data -type f ! -perm 0644 -exec chmod -f 0644 '{}' +
    find /opt/couchdb/etc -type d ! -perm 0755 -exec chmod -f 0755 '{}' +
    find /opt/couchdb/etc -type f ! -perm 0644 -exec chmod -f 0644 '{}' +
  fi

  if [ -n "$NODENAME" ] && ! grep "couchdb@" /opt/couchdb/etc/vm.args; then
    echo "-name couchdb@$NODENAME" >>/opt/couchdb/etc/vm.args
  fi

  if [ -n "$RUN_AS" ]; then
    if ! grep -sPzoqr "\[admins\]\n$RUN_AS =" /opt/couchdb/etc/local.d/*.ini /opt/couchdb/etc/local.ini; then
      printf "\n[admins]\n%s = %s\n" "$RUN_AS" "$RUN_AS" >>/opt/couchdb/etc/local.d/docker.ini
    fi
  fi

  if [ -n "$COUCHDB_SECRET" ]; then
    if ! grep -sPzoqr "\[chttpd_auth\]\nsecret =" /opt/couchdb/etc/local.d/*.ini /opt/couchdb/etc/local.ini; then
      printf "\n[chttpd_auth]\nsecret = %s\n" "$COUCHDB_SECRET" >>/opt/couchdb/etc/local.d/docker.ini
    fi
  fi

  if [ -n "$COUCHDB_ERLANG_COOKIE" ]; then
    cookieFile='/opt/couchdb/.erlang.cookie'
    if [ -e "$cookieFile" ]; then
      if [ "$(cat "$cookieFile" 2>/dev/null)" != "$COUCHDB_ERLANG_COOKIE" ]; then
        echo >&2
        echo >&2 "warning: $cookieFile contents do not match COUCHDB_ERLANG_COOKIE"
        echo >&2
      fi
    else
      echo "$COUCHDB_ERLANG_COOKIE" >"$cookieFile"
    fi
    chown $RUN_AS:$RUN_AS "$cookieFile"
    chmod 600 "$cookieFile"
  fi

  if [ "$(id -u)" = '0' ]; then
    chown -f $RUN_AS:$RUN_AS /opt/couchdb/etc/local.d/docker.ini || true
  fi

  if ! grep -Pzoqr '\[admins\]\n[^;]\w+' /opt/couchdb/etc/default.d/*.ini /opt/couchdb/etc/local.d/*.ini /opt/couchdb/etc/local.ini; then
    cat >&2 <<-'EOWARN'
*************************************************************
ERROR: CouchDB 3.0+ will no longer run in "Admin Party"
       mode. You *MUST* specify an admin user and
       password, either via your own .ini file mapped
       into the container at /opt/couchdb/etc/local.ini
       or inside /opt/couchdb/etc/local.d, or with
       "-e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password"
       to set it via "docker run".
*************************************************************
EOWARN
    exit 1
  fi
  if [ "$(id -u)" = '0' ]; then
    __exec_command gosu $RUN_AS /opt/couchdb/bin/couchdb
  fi

  echo "This script should be called by root user"
  ;;
esac
