#!/bin/sh
# uses dynamicly set DB information and injects it into the mariadb-secrets.txt

# OS Detection
KERNEL="$(uname -s)"

basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh

if [ -z ${MD_DB_TABLE+x} ] || [ -z ${MD_USER_TABLE+x} ] || [ -z ${MD_PW_TABLE+x} ]; then
	logp fatal "Couldn't finalize dynamic variables for mariadab -> variables not set!"
fi

if [ ${#MD_DB_TABLE[@]} != ${#MD_PW_TABLE[@]} ] || [ ${#MD_DB_TABLE[@]} != ${#MD_USER_TABLE[@]} ]; then
	logp fatal "Couldn't finalize dynamic variables for mariadab -> not all variables are set!"
fi

export MD_DB_TABLE="$MD_DB_TABLE )"
export MD_USER_TABLE="$MD_USER_TABLE )"
export MD_PW_TABLE="$MD_PW_TABLE )"

function replace()
{
	var=$1 file=$2
	if [ $KERNEL == "Linux" ]; then sed -i "s|__${var}__|${!var}|g" $file
	else                            sed -i '' "s|__${var}__|${!var}|g" $file; fi
	return $?
}

replace MD_DB_TABLE $basedir/mariadb-secrets.txt || exit $?
replace MD_USER_TABLE $basedir/mariadb-secrets.txt || exit $?
replace MD_PW_TABLE $basedir/mariadb-secrets.txt || exit $?

exit $?
