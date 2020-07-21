FROM alpine:latest

RUN apk update && apk upgrade && apk add influxdb curl jq bash && rm -rf /var/cache/apk/*

COPY docker-srcs/run-influxdbd.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run-influxdb.sh

COPY docker-srcs/get_ip.sh /usr/sbin/get_ip.sh
RUN chmod 755 /usr/sbin/get_ip.sh

RUN mv /etc/influxdb/influxdb.conf /etc/influxdb/influxdb.conf.orig
COPY docker-srcs/influxdb.conf /etc/influxdb/influxdb.conf

EXPOSE 21
EXPOSE 21000

CMD ["/usr/sbin/run-influxdb.sh"]
