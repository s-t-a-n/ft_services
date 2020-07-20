FROM alpine:latest

RUN apk update && apk upgrade && apk add vsftpd openssl curl jq bash && rm -rf /var/cache/apk/*

COPY docker-srcs/run-vsftpd.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run-vsftpd.sh

COPY docker-srcs/get_ip.sh /usr/sbin/get_ip.sh
RUN chmod 755 /usr/sbin/get_ip.sh

RUN mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.orig
COPY docker-srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 21
EXPOSE 21000

CMD ["/usr/sbin/run-vsftpd.sh"]
