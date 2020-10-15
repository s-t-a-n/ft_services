FROM alpine:latest

ENV NAME="grafana"

ENV PACKAGES="supervisor openssh"

ENV DOCKER_SRC="docker-srcs"
ENV GLOB_CONT_SCRIPTS="$DOCKER_SRC/global_container_scripts"
ENV GLOB_CONT_CONFS="$DOCKER_SRC/global_container_confs"

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

RUN apk update && apk upgrade && apk add $PACKAGES && rm -rf /var/cache/apk/*
RUN apk update && apk add grafana telegraf --repository "$(head -n1 /etc/apk/repositories | rev | cut -d '/' -f3- | rev)/edge/testing" --allow-untrusted --no-cache && rm -rf /var/cache/apk/*
RUN apk add --no-cache su-exec ca-certificates openssl
RUN apk add --no-cache --virtual .build-deps fontconfig
RUN apk add --no-cache libc6-compat ca-certificates su-exec bash

RUN mv /etc/grafana.ini /etc/grafana.ini.orig
COPY $DOCKER_SRC/grafana.ini "$GF_PATHS_CONFIG"

RUN mkdir -p "$GF_PATHS_HOME/.aws" \
    && mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
        "$GF_PATHS_PROVISIONING/dashboards" \
        "$GF_PATHS_PROVISIONING/notifiers" \
        "$GF_PATHS_LOGS" \
        "$GF_PATHS_PLUGINS" \
        "$GF_PATHS_DATA" \
    && chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" \
    && chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"

# thank you Peer (https://github.com/pde-bakk/ft_services/blob/master/srcs/grafana/Dockerfile)
RUN mkdir -p $GF_PATHS_PROVISIONING/datasources
COPY $DOCKER_SRC/datasource.yaml $GF_PATHS_PROVISIONING/datasources/

RUN mkdir -p $GF_PATHS_PROVISIONING/dashboards/mine
COPY $DOCKER_SRC/dashboards/*.json $GF_PATHS_PROVISIONING/dashboards/mine/
COPY $DOCKER_SRC/dashboards/default.yaml $GF_PATHS_PROVISIONING/dashboards/
RUN chown -R grafana:grafana $GF_PATHS_PROVISIONING

COPY $DOCKER_SRC/grafana-server_wrapper.sh /usr/sbin/
RUN chmod 755 /usr/sbin/grafana-server_wrapper.sh

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

EXPOSE 3000
