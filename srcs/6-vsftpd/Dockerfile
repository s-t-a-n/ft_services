FROM alpine:latest

RUN apk update && apk upgrade && apk add vsftpd openssl curl jq && rm -rf /var/cache/apk/*

COPY docker-srcs/run-vsftpd.sh /usr/sbin/
RUN chmod 755 /usr/sbin/run-vsftpd.sh

RUN mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.orig
COPY docker-srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 21
EXPOSE 21000

CMD ["/usr/sbin/run-vsftpd.sh"]
