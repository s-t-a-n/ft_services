#!/bin/sh

# OS Detection
KERNEL="$(uname -s)"

function insert_variables()
{
	if [ ! -f $1 ] || [ ! -f $2 ]; then logp fatal "insert_variables expects a src and dst file!"; fi;
	logp info_nnl "Inserting variables in working directory... "
	SRC=$1
	DST=$2

	source $SRC || return 1
	shopt -s dotglob
	while read -u 11 line; do
		var="$(echo $line | cut -d= -f1)"
		if [ $KERNEL = "Linux" ]; then	sed -i "s|__${var}__|${!var}|g" $DST || return 1
		else							sed -i '' "s|__${var}__|${!var}|g" $DST || return 1
		fi
	done 11<$SRC
	echo "done!"
}
