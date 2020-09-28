FROM alpine:latest

ENV NAME="nginx"

ENV PACKAGES="supervisor openssh openssl curl jq bash nginx"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

RUN apk update && apk upgrade && apk add $PACKAGES && rm -rf /var/cache/apk/*

RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
COPY $DOCKER_SRC/nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/sites-available && mkdir -p /etc/nginx/sites-enabled

RUN mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

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
#COPY $DOCKER_SRC/dev-sec_nginx_hardening.yml /root/
#COPY $DOCKER_SRC/dev-sec_os_hardening.yml /root/
#RUN ansible-galaxy install dev-sec.nginx-hardening && ansible-playbook /root/dev-sec_nginx_hardening.yml && rm -f /root/dev-sec_nginx_hardening.yml
#RUN ansible-galaxy install dev-sec.os-hardening && ansible-playbook /root/dev-sec_os_hardening.yml && rm -f /root/dev-sec_os_hardening.yml
##! HARDENING #

EXPOSE 80
EXPOSE 443
