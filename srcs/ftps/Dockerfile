FROM alpine

ENV PUREFTPD_VERSION=1.0.42-r0 \
    SYSLOG_STDOUT_VERSION=1.1.1

RUN printf '%s\n' \
      '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' \
      >> /etc/apk/repositories \
    && apk update \
    && apk add pure-ftpd@testing=1.0.49-r0

COPY entrypoint-target /entrypoint

ENTRYPOINT sh /entrypoint


# Explications : ---------------------------------------------------------------

# Notes :
# With Pure-FTPd, it's possible to use virtual users instead of real system users.
# ENV commands are required or Docker will fetch unecessary files
#
# Le certificat self-signed a été généré via la commande shell suivante :
# openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -subj "/C=FR/ST=fr/L=Paris/O=42/CN=hberger"  > srcs/ftps/pure-ftpd.pem
# avec chmod 600 sur le fichier .pem, ce fichier doit se trouver dans /etc/ssl/private
#

# Sources :
#
# 	--> https://github.com/gimoh/docker-pureftpd/blob/master/Dockerfile
# 	--> https://wiki.archlinux.org/index.php/Pure-FTPd

# vsftpd :  https://doc.fedora-fr.org/wiki/Vsftpd_:_Installation_et_configuration
# 			https://tn710617.github.io/ftpServer/

# https://hub.docker.com/r/forumi0721alpinearmhf/alpine-armhf-vsftpd/
