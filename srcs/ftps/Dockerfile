# Sources :
#
# 	--> https://github.com/gimoh/docker-pureftpd/blob/master/Dockerfile
# 	--> https://wiki.archlinux.org/index.php/Pure-FTPd

# Notes :
# With Pure-FTPd, it's possible to use virtual users instead of real system users.
# ENV commands are required or Docker will fetch unecessary files
#
# Le certificat self-signed a été généré via la commande shell suivante :
# openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -subj "/C=FR/ST=fr/L=Paris/O=42/CN=hberger"  > srcs/ftps/pure-ftpd.pem
# avec chmod 600 sur le fichier .pem, ce fichier doit se trouver dans /etc/ssl/private
#
# ENTRYPOINT allows you to configure a container that will run as an executable.

FROM			alpine
ENV				PUREFTPD_VERSION=1.0.42-r0
ENV				SYSLOG_STDOUT_VERSION=1.1.1
RUN				printf '%s\n' \
				'@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' \
				>> /etc/apk/repositories
RUN				apk update
RUN				apk add pure-ftpd@testing=1.0.49-r0
COPY			ftpsStartIPUpdated /ftpsStart
COPY			pure-ftpd.pem /etc/ssl/private/
ENTRYPOINT		sh /ftpsStart

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Debug section <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# RUN				ls /etc/ssl/private/
