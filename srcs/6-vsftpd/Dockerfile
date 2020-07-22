FROM alpine:latest

ENV NAME="vsftpd"

ENV PACKAGES="supervisor openssh openssl curl jq bash vsftpd"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

RUN apk update && apk upgrade && apk add $PACKAGES && rm -rf /var/cache/apk/*

COPY docker-srcs/run.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run.sh

COPY docker-srcs/global_container_scripts/get_ip.sh /usr/sbin/get_ip.sh
RUN chmod 755 /usr/sbin/get_ip.sh

RUN mkdir -p /etc/supervisord/conf.d
RUN mv /etc/supervisord.conf /etc/supervisord/supervisord.conf.orig
COPY $GLOB_CONT_CONFS/supervisord.conf /etc/supervisord/supervisord.conf
COPY $DOCKER_SRC/services.conf /etc/supervisord/conf.d

RUN mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.orig
COPY $DOCKER_SRC/vsftpd.conf /etc/vsftpd/vsftpd.conf

COPY $GLOB_CONT_SCRIPTS/supervisor-kill.sh /usr/sbin/
RUN chmod 755 /usr/sbin/supervisor-kill.sh

RUN ssh-keygen -A

EXPOSE 21
EXPOSE 22
EXPOSE 21000

CMD ["/usr/sbin/run.sh"]
