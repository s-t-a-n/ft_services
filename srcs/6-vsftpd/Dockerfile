FROM alpine:latest

ENV NAME="vsftpd"

ENV PACKAGES="supervisor openssh openssl curl jq bash vsftpd"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

RUN apk update && apk upgrade && apk add $PACKAGES && rm -rf /var/cache/apk/*

COPY $DOCKER_SRC/run.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run.sh

COPY $DOCKER_SRC/global_container_scripts/get_ip.sh /usr/sbin/get_ip.sh
RUN chmod 755 /usr/sbin/get_ip.sh

RUN mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.orig
COPY $DOCKER_SRC/vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN	echo __CLUSTER_ADMIN__ >> /etc/vsftpd.userlist

# GLOBAL
RUN mkdir -p /etc/supervisord/conf.d
RUN mv /etc/supervisord.conf /etc/supervisord/supervisord.conf.orig
COPY $GLOB_CONT_CONFS/supervisord.conf /etc/supervisord/supervisord.conf
COPY $DOCKER_SRC/services.conf /etc/supervisord/conf.d

RUN	adduser $CLUSTER_ADMIN --disabled-password
RUN	echo "__CLUSTER_ADMIN__:__CLUSTER_ADMIN_PW__" | chpasswd

RUN	mkdir -p /home/__CLUSTER_ADMIN__/.ssh
RUN	chmod 700 /home/__CLUSTER_ADMIN__/.ssh/
RUN	echo "__CLUSTER_ADMIN_SSHPUB__" > /home/__CLUSTER_ADMIN__/.ssh/authorized_keys
RUN	chmod 500 /home/__CLUSTER_ADMIN__/.ssh/authorized_keys
RUN	chown -R __CLUSTER_ADMIN__:__CLUSTER_ADMIN__ /home/__CLUSTER_ADMIN__

COPY $GLOB_CONT_SCRIPTS/supervisor-kill.sh /usr/sbin/
RUN chmod 755 /usr/sbin/supervisor-kill.sh

RUN ssh-keygen -A

EXPOSE 21
EXPOSE 22
EXPOSE 21000

CMD ["/usr/sbin/run.sh"]
