FROM alpine:latest

ENV NAME="influxdb"

ENV PACKAGES="supervisor bash wget openssh influxdb"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

RUN apk update && apk upgrade && apk add $PACKAGES && rm -rf /var/cache/apk/*

RUN mv /etc/influxdb.conf /etc/influxdb.conf.orig
COPY $DOCKER_SRC/influxdb.conf /etc/influxdb.conf

# UNIVERSAL #
COPY $DOCKER_SRC/run.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run.sh

RUN mkdir -p /etc/supervisord/conf.d
RUN mv /etc/supervisord.conf /etc/supervisord/supervisord.conf.orig
COPY $GLOB_CONT_CONFS/supervisord.conf /etc/supervisord/supervisord.conf
COPY $DOCKER_SRC/services.conf /etc/supervisord/conf.d

RUN	adduser __CLUSTER_ADMIN__ --disabled-password
RUN	echo "__CLUSTER_ADMIN__:__CLUSTER_ADMIN_PW__" | chpasswd

RUN	mkdir -p /home/__CLUSTER_ADMIN__/.ssh
RUN	chmod 700 /home/__CLUSTER_ADMIN__/.ssh/
RUN	echo "__CLUSTER_ADMIN_SSHPUB__" > /home/__CLUSTER_ADMIN__/.ssh/authorized_keys
RUN	chmod 500 /home/__CLUSTER_ADMIN__/.ssh/authorized_keys
RUN	chown -R __CLUSTER_ADMIN__:__CLUSTER_ADMIN__ /home/__CLUSTER_ADMIN__

COPY $GLOB_CONT_SCRIPTS/supervisor-kill.sh /usr/sbin/
RUN chmod 755 /usr/sbin/supervisor-kill.sh

RUN ssh-keygen -A
EXPOSE 22
CMD ["/usr/sbin/run.sh"]
#! UNIVERSAL #

EXPOSE 8086
