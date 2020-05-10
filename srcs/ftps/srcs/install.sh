#!/bin/sh

# FTP Server
apk upgrade
apk add openrc openssl --no-cache
apk add telegraf pure-ftpd --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache

# SSL
yes "" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
adduser -D "__FTPS_USERNAME__"
echo "__FTPS_USERNAME__:__FTPS_PASSWORD__" | chpasswd

openrc
touch /run/openrc/softlevel
rc-update add telegraf

# Notes personnelles

# OpenRC : OpenRC est un remplaçant du démon init system V pour Linux
# Le rôle de init est de démarrer et d’arrêter tous les services.
# C’est init qui va exécuter les diverses tâches initiales nécessaires au
# bon fonctionnement de Linux via l’exécution de plusieurs commandes
# Pour configurer un service : rc-update add nomduservice
