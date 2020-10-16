#!/bin/sh

function queue_influxdb_injection()
{
	if [ ! $# -eq 2 ]; then
		logp fatal "queue_influxdb_injection expects db parameters and file as parameters!"
	fi

	INFLUXDB_DATABASE=$1
	#INFLUXDB_USER=$2
	#INFLUXDB_PASSWORD=$3
	QUEUE_F=$2

	if [ ! -f $QUEUE_F ]; then
		logp info "Setting up $QUEUE_F.."
		touch $QUEUE_F || logp fatal "Couldn't setup influxdb injection queue: $QUEUE_F"
	fi
	
	if [ -n "${INFLUXDB_DATABASE}" ]; then
		echo "create database ${INFLUXDB_DATABASE}" >> $QUEUE_F
	fi
	#if [ -n "${INFLUXDB_USER}" ] && [ "${INFLUXDB_DATABASE}" ]; then
	#	# mysql syntax -> echo "grant all on \`${INFLUXDB_DATABASE}\`.* to '${INFLUXDB_USER}'@'%' identified by '${INFLUXDB_PASSWORD}'; " >> $QUEUE_F
	#fi
}
