function setUpUserDB(){
  echo "=> setting up fh-SUPERCORE db.. ";

  # exit if user exists
  local js_command="db.system.users.count({'user':'${MONGODB_USERDB_USER}'})"
  if [ "$(mongo admin --quiet --eval "$js_command")" == "1" ]; then
    echo "=> ${MONGODB_USERDB_USER} user is already created. No action taken"
  else
    js_command="db.getSiblingDB('${MONGODB_USERDB_DATABASE}').createUser({user: '${MONGODB_USERDB_USER}', pwd: '${MONGODB_USERDB_PASSWORD}', roles: [ 'readWrite' ]})"
    if ! mongo admin ${1:-} --host ${2:-"localhost"} --eval "${js_command}"; then
      echo "=> Failed to create MongoDB user: ${MONGODB_USERDB_USER}"
      exit 1
    fi
  fi
}

function setUpDatabases(){
  echo "=> setting up Custom databases";
  if [[ -v MONGODB_FHMBAAS_DATABASE && -v MONGODB_FHMBAAS_USER && -v MONGODB_FHMBAAS_PASSWORD ]]
  then
      setUpUserDB "$@"
  fi
}
