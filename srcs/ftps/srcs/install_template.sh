#!/bin/sh

# FTP Server
apk upgrade
apk add openrc openssl --no-cache # fbnote: implémentation des algorithmes cryptographiques et du protocole de communication SSL/TLS, ainsi qu'une interface en ligne de commande, openssl
# fbnote: OpenRC : OpenRC est un remplaçant du démon init system V pour Linux
# fbnote: Le rôle de init est de démarrer et d’arrêter tous les services.
# fbnote: C’est init qui va exécuter les diverses tâches initiales nécessaires au
# fbnote: bon fonctionnement de Linux via l’exécution de plusieurs commandes
# fbnote: Pour configurer un service : rc-update add nomduservice
apk add telegraf pure-ftpd --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache

# SSL
yes "" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
# We want a specific user account for the SSH connection. We’ll allow access to this account and no other.
adduser -D "__FTPS_USERNAME__"
# Next need to decide how to authenticate the user. It’s possible to allow username / password authentication but this is inadvisable.
echo "__FTPS_USERNAME__:__FTPS_PASSWORD__" | chpasswd

openrc
# OpenRC won't work in a container where it is not pid 1.
touch /run/openrc/softlevel #fbquestion?
# once openrc starts running, it creates /run/openrc
#  * You are attempting to run an openrc service on a
#  * system which openrc did not boot.
#  * You may be inside a chroot or you may have used
#  * another initialization system to boot this system.
#  * In this situation, you will get unpredictable results!
#  * If you really want to do this, issue the following command:
#  * touch /run/openrc/softlevel
rc-update add telegraf
# Rather than editing some obscure file or managing a directory of symlinks, rc-update exists to quickly add or delete services 