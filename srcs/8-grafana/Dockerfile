FROM alpine:latest

ENV NAME="grafana"

ENV PACKAGES="supervisor openssh"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

RUN apk update && apk upgrade && apk add $PACKAGES && rm -rf /var/cache/apk/*
RUN apk update && apk add grafana telegraf --repository "$(head -n1 /etc/apk/repositories | rev | cut -d '/' -f3- | rev)/edge/testing" --allow-untrusted --no-cache && rm -rf /var/cache/apk/*
RUN apk add --no-cache su-exec ca-certificates openssl
RUN apk add --no-cache --virtual .build-deps fontconfig

COPY $DOCKER_SRC/run.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run.sh

RUN mkdir -p /etc/supervisord/conf.d
RUN mv /etc/supervisord.conf /etc/supervisord/supervisord.conf.orig
COPY $GLOB_CONT_CONFS/supervisord.conf /etc/supervisord/supervisord.conf
COPY $DOCKER_SRC/services.conf /etc/supervisord/conf.d

RUN mv /etc/grafana.ini /etc/grafana.ini.orig
COPY $DOCKER_SRC/grafana.ini /etc/grafana.ini

COPY $GLOB_CONT_SCRIPTS/supervisor-kill.sh /usr/sbin/
RUN chmod 755 /usr/sbin/supervisor-kill.sh

RUN ssh-keygen -A

EXPOSE 22
EXPOSE 3000

CMD ["/usr/sbin/run.sh"]
