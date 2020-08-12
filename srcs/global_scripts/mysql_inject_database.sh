#!/bin/sh

function inject_databases()
{
	echo ARGUMENTS : $@

	if [ ! $# -eq 4 ]; then
		logp fatal "mysql_inject_database expects queue_file, user, pw and host as parameters!"
	fi

	if [ ! -f $1 ]; then
		logp info "No queue file found. Skipping database injection."
	else
		logp info "Injecting databases @ $4..."

		QUEUE_F=$1
		USER=$2
		PW=$3
		HOST=$4
		kubectl cp $QUEUE_F $HOST:/tmp/queue.sql || logp fatal "Couldn't copy over $QUEUE_F to $HOST!"
		kubectl exec $HOST -- "sh -c /tmp/queue.sql" || logp fatal "Failed to execute /tmp/queue.sql on $HOST!"
		#mysql -u "$USER" -p "$PW" -h $HOST < $QUEUE_F
	fi
}
