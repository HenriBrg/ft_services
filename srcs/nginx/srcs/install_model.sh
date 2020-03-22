#!/bin/sh

apk update
apk add openrc nginx openssl openssh --no-cache
apk add telegraf --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache
yes "" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
adduser -D "__SSH_USERNAME__"
echo "__SSH_USERNAME__:__SSH_PASSWORD__" | chpasswd
mkdir -p /run/nginx
openrc
touch /run/openrc/softlevel
rc-update add sshd
rc-update add telegraf
