FROM alpine:latest

ENV NAME="phpfpm"

ARG PHP_VERSION
ARG PHPFPM_VERSION

ENV PACKAGES="supervisor openssh openssl curl jq bash"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

RUN apk update && apk upgrade												\
	&& apk add $PACKAGES													\
	&& apk add "php$(echo $PHPFPM_VERSION | cut -d\. -f0)-fpm<$PHPFPM_VERSION"\
	&& apk add "php$(echo $PHP_VERSION | cut -d\. -f0)<$PHP_VERSION"		\
	&& rm -rf /var/cache/apk/*

COPY $DOCKER_SRC/php-fpm_wrap.sh /usr/sbin/
RUN chmod 700 /usr/sbin/php-fpm_wrap.sh

RUN mkdir -p /prestage/php-fpm.d && mkdir -p /prestage/conf.d
COPY $DOCKER_SRC/php/php.ini /prestage/
COPY $DOCKER_SRC/php/php-fpm.conf /prestage/
COPY $DOCKER_SRC/php/php-fpm.d /prestage/php-fpm.d
COPY $DOCKER_SRC/php/conf.d /prestage/conf.d
RUN cp -r /prestage/* /etc/php$(echo $PHP_VERSION | cut -d\. -f0)/ && rm -rf /prestage/

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

## HARDENING #
#RUN apk add ansible
#COPY $DOCKER_SRC/dev-sec_os_hardening.yml /root/
#RUN ansible-galaxy install dev-sec.os-hardening && ansible-playbook /root/dev-sec_os_hardening.yml && rm -f /root/dev-sec_os_hardening.yml
##! HARDENING #

EXPOSE 9000
