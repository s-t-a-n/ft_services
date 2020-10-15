#!/bin/sh

function inject_influxdb()
{
	if [ ! $# -eq 2 ]; then
		logp fatal "inject_influxdb expects queue_file and host as parameters!"
	fi

	if [ ! -f $1 ]; then
		logp info "No queue file found. Skipping influxdb injection."
	else
		logp info "Injecting influxdb @ $2 from input file $1..."

		QUEUE_F="$1"
		HOST="$2"
		TMPF=/tmp/queue.influx
		kubectl cp "$QUEUE_F" "$HOST":$TMPF || logp fatal "Couldn't copy over $QUEUE_F to $HOST!"
		kubectl exec $HOST -- bash -c "influx < $TMPF && rm $TMPF" || logp fatal "Failed to execute /tmp/queue.influx on $HOST!"
	fi
}
