#!/bin/sh

function inject_site()
{
	if [ ! $# -eq 2 ]; then
		logp fatal "inject_site expects queue_file and host as parameter!"
	fi

	if [ ! -f $1 ]; then
		logp info "No queue file found. Skipping site injection."
	else
		logp info "Injecting sites @ $2 from input file $1..."

		QUEUE_F="$1"
		POD="$2"
		sed -i'' "s/__POD__/$POD/g" $QUEUE_F								\
		&& sh $QUEUE_F														\
		|| logp fatal "Failed to inject site @ $POD from input file $1"

		return $?
	fi
}
