#!/bin/sh

function queue_site_injection()
{
	if [ ! $# -eq 3 ]; then
		logp fatal "queue_site_injection expects nginx.conf, root directory and queue file as parameters!"
	fi

	CONF=$1
	DATA=$2
	QUEUE_F=$3

	if [ ! -f $QUEUE_F ]; then
		logp info "Setting up $QUEUE_F.."
		touch $QUEUE_F || logp fatal "Couldn't setup nginx injection queue: $QUEUE_F"
	fi
	
	echo "kubectl cp $CONF __POD__:/etc/nginx/sites-available/" >> $QUEUE_F	\
	&& echo "kubectl exec __POD__ -- bash -c \"cd /etc/nginx/sites-enabled && ln -s ../sites-available/$(basename $CONF)./\"" >> $QUEUE_F															\
	&& echo "kubectl exec __POD__ -- bash -c \"nginx -s reload\"" >> $QUEUE_F \
	&& echo "kubectl cp $DATA __POD__:/data/http/" >> $QUEUE_F				\
	|| logp fatal "queue_site_injection couldn't add rules to queue file $QUEUE_F"

	return $?
}
