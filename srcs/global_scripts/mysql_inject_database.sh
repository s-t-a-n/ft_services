#!/bin/sh

function inject_databases()
{
	if [ ! $# -eq 2 ]; then
		logp fatal "mysql_inject_database expects queue_file and host as parameters!"
	fi

	if [ ! -f $1 ]; then
		logp info "No queue file found. Skipping database injection."
	else
		logp info "Injecting databases @ $2..."

		QUEUE_F="$1"
		HOST="$2"
		TMPF=/tmp/queue.sql
		kubectl cp "$QUEUE_F" "$HOST":$TMPF || logp fatal "Couldn't copy over $QUEUE_F to $HOST!"
		kubectl exec $HOST -- bash -c "mysql < $TMPF && rm $TMPF" || logp fatal "Failed to execute /tmp/queue.sql on $HOST!"
	fi
}
