FROM	alpine:latest

RUN		apk update
RUN		apk add --no-cache --upgrade bash
RUN		apk add nginx
RUN		apk add openssl

# $ mkdir -p : S'assurer que  chaque  répertoire  indiqué  existe. Créer   les   répertoires  parents  manquants.  Ces
# derniers sont  créés  avec  l'autorisation  d'accès umask  modifiée  par  `u+wx'

RUN		mkdir -p /var/run/nginx
RUN		adduser -D 'www' www
RUN		mkdir /www

# chown -R : Modifier  récursivement  l'appartenance  des réper­toires et de leurs contenus.

RUN		chown -R www:www /var/lib/nginx
RUN		chown -R www:www /www

# Alpine user management : https://stackoverflow.com/questions/49955097/how-do-i-add-a-user-when-im-using-alpine-as-a-base-image

RUN		mkdir /etc/nginx/ssl
RUN		openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/nginx/ssl/www.pem -keyout /etc/nginx/ssl/www.key -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=hberger/CN=ft_services"

RUN		rm -v /etc/nginx/nginx.conf
COPY	./nginx.conf /etc/nginx/nginx.conf

# Source : https://www.digitalocean.com/community/tutorials/docker-explained-how-to-containerize-and-use-nginx-as-a-proxy
# https://github.com/nginxinc/docker-nginx/issues/41#issuecomment-140713002

CMD [ "nginx" , "-g", "daemon off;" ]
