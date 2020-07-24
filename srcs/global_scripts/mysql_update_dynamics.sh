#!/bin/sh

basedir=$(dirname "$0")
source $basedir/logp.sh

echo ALL PARAMS $@

if [ -z ${MD_DB_TABLE+x} ] || [ -z ${MD_USER_TABLE+x} ] || [ -z ${MD_PW_TABLE+x} ]; then
	logp fatal "Couldn't finalize dynamic variables for mariadab -> variables not set!"
fi

if [ ${#MD_DB_TABLE[@]} != ${#MD_PW_TABLE[@]} ] || [ ${#MD_DB_TABLE[@]} != ${#MD_USER_TABLE[@]} ]; then
	logp fatal "Couldn't finalize dynamic variables for mariadab -> not all variables are set!"
fi

if [ ! $# -eq 3 ]; then
	logp fatal "mysql_update_dynamics expects three parameters"
fi


export MD_DB_TABLE="$MD_DB_TABLE $1"
export MD_USER_TABLE="$MD_USER_TABLE $2"
export MD_PW_TABLE="$MD_PW_TABLE $3"
