FROM alpine

LABEL maintainer Stan Verschuuren <sverschu@student.codam.nl>

RUN apk --update add vsftpd

EXPOSE 21

CMD ["/usr/sbin/run-vsftpd.sh"]
