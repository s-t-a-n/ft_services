#!/bin/sh

function queue_database_injection()
{
	echo ARGUMENTS: $@, arg count : $#

	if [ ! $# -eq 4 ]; then
		logp fatal "queue_database_injection expects db parameters and file as parameters!"
	fi

	MYSQL_DATABASE=$1
	MYSQL_USER=$2
	MYSQL_PASSWORD=$3
	QUEUE_F=$4

	if [ ! -f $QUEUE_F ]; then
		logp info "Setting up $QUEUE_F.."
		touch $QUEUE_F || logp fatal "Couldn't setup mysql injection queue: $QUEUE_F"
	fi
	
	if [ -n "${MYSQL_DATABASE}" ]; then
		[ -n "${MYSQL_CHARSET}" ] || MYSQL_CHARSET="utf8"
		[ -n "${MYSQL_COLLATION}" ] && MYSQL_COLLATION="collate '${MYSQL_COLLATION}'"
		echo "create database if not exists \`${MYSQL_DATABASE}\` character set '${MYSQL_CHARSET}' ${MYSQL_COLLATION}; " >> $QUEUE_F
	fi
	if [ -n "${MYSQL_USER}" ] && [ "${MYSQL_DATABASE}" ]; then
		echo "grant all on \`${MYSQL_DATABASE}\`.* to '${MYSQL_USER}'@'%' identified by '${MYSQL_PASSWORD}'; " >> $QUEUE_F
	fi
	echo "flush privileges;" >> $QUEUE_F
}
