# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lmartin <lmartin@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/02/06 05:23:46 by lmartin           #+#    #+#              #
#    Updated: 2020/05/07 23:42:39 by henri            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
#!/bin/bash

if [[ $1 == "clean" ]]
then
	if minikube status > /dev/null 2>&1
	then
		echo "Cleaning all Kubectl ressources ..."
		kubectl		delete all --all
		minikube	delete
		echo "... Done"
		exit
	else
		echo "Minikube isn't running, nothing to clean"
		exit 1
	fi
fi


# <><><><><><><><><><><><><><><><><> VARIABLES <><><><><><><><><><><><><><><><><

# Directories
srcs=./srcs
dir_goinfre=/Users/$USER # /goinfre/$USER at 42 or /sgoinfre - /Users/$USER at home on Mac
docker_destination=$dir_goinfre/docker
dir_minikube=$dir_goinfre/minikube
dir_archive=$dir_goinfre/images-archives
volumes=$srcs/volumes

SSH_USERNAME=admin
SSH_PASSWORD=admin
FTPS_USERNAME=admin
FTPS_PASSWORD=admin
DB_USER=root
DB_PASSWORD=password

services=(nginx ftps wordpress mysql phpmyadmin grafana influxdb)
pvs=(wp mysql influxdb)

if [[ $1 != "deployment" ]]
then
		# which -s brew
		# if [[ $? != 0 ]] ; then
		# 	echo "Brew not installed, installling..."
		# 	# Install brew
		# 	rm -rf $HOME/.brew
		# 	git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew
		# 	echo 'export PATH=$HOME/.brew/bin:$PATH' >> $HOME/.zshrc
		# 	source $HOME/.zshrc
		# fi
		# echo "Updating brew..."
		# brew update > /dev/null

		# # KUBECTL
		# which -s kubectl
		# if [[ $? != 0 ]] ; then
		# 	echo "Kubectl not installed, installing..."
		# 	brew install kubectl
		# fi

		# MINIKUBE
		# which -s minikube
		# if [[ $? != 0 ]] ; then
		# 	echo "Minikube not installed, installing..."
		# 	# Install minikube
		# 	brew install minikube
		# fi
		mkdir -p $dir_minikube
		ln -sf $dir_minikube /Users/$USER/.minikube

		# pkill Docker
		# if [ ! -d $docker_destination ]; then
		# 	rm -rf ~/Library/Containers/com.docker.docker ~/.docker
		# 	mkdir -p $docker_destination/{com.docker.docker,.docker}
		# 	ln -sf $docker_destination/com.docker.docker ~/Library/Containers/com.docker.docker
		# 	ln -sf $docker_destination/.docker ~/.docker
		# fi

		docker_state=$(docker info >/dev/null 2>&1)
		if [[ $? -ne 0 ]]; then
			echo "Opening Docker..."
			open -g -a Docker > /dev/null
		fi

		# DOCKER-MACHINE
		# which -s docker-machine
		# if [[ $? != 0 ]] ; then
		# 	echo "docker-machine not installed, installing..."
		# 	# Install docker-machine
		# 	brew install docker-machine
		# fi

		docker-machine stop > /dev/null
		minikube delete

		docker-machine create --driver virtualbox default > /dev/null
		docker-machine start

		# Launch Minikube
		minikube start --cpus=2 --disk-size 11000 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000
		minikube addons enable dashboard
		minikube addons enable ingress
		minikube addons enable metrics-server

		#If error
		#VBoxManage hostonlyif remove vboxnet1

		minikube ip > /tmp/.minikube.ip
fi

# ============================== REPLACE MODELS ================================

MINIKUBE_IP=`cat /tmp/.minikube.ip`;

# copy models files
cp $srcs/nginx/srcs/install_model.sh 			$srcs/nginx/srcs/install.sh
cp $srcs/ftps/srcs/install_model.sh 			$srcs/ftps/srcs/install.sh
cp $srcs/ftps/Dockerfile_model					$srcs/ftps/Dockerfile
cp $srcs/wordpress/srcs/wp-config_model.php		$srcs/wordpress/srcs/wp-config.php
cp $srcs/mysql/srcs/start_model.sh				$srcs/mysql/srcs/start.sh
cp $srcs/wordpress/srcs/wordpress_model.sql		$srcs/wordpress/srcs/wordpress.sql
cp $srcs/grafana/srcs/global_model.json			$srcs/grafana/srcs/global.json
cp $srcs/nginx/srcs/index_model.html			$srcs/nginx/srcs/index.html

cp $srcs/telegraf_model.conf					$srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/nginx/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/ftps/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/mysql/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/wordpress/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/phpmyadmin/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/grafana/srcs/telegraf.conf

sed -i '' s/__SSH_USERNAME__/$SSH_USERNAME/g	$srcs/nginx/srcs/install.sh
sed -i '' s/__SSH_PASSWORD__/$SSH_PASSWORD/g	$srcs/nginx/srcs/install.sh
sed -i '' s/__FTPS_USERNAME__/$FTPS_USERNAME/g	$srcs/ftps/srcs/install.sh
sed -i '' s/__FTPS_PASSWORD__/$FTPS_PASSWORD/g	$srcs/ftps/srcs/install.sh
sed -i '' s/__MINIKUBE_IP__/$MINIKUBE_IP/g		$srcs/ftps/Dockerfile
sed -i '' s/__DB_USER__/$DB_USER/g				$srcs/wordpress/srcs/wp-config.php
sed -i '' s/__DB_PASSWORD__/$DB_PASSWORD/g		$srcs/wordpress/srcs/wp-config.php
sed -i '' s/__DB_USER__/$DB_USER/g				$srcs/mysql/srcs/start.sh
sed -i '' s/__DB_PASSWORD__/$DB_PASSWORD/g		$srcs/mysql/srcs/start.sh
sed -i '' s/__MINIKUBE_IP__/$MINIKUBE_IP/g		$srcs/wordpress/srcs/wordpress.sql
sed -i '' s/__MINIKUBE_IP__/$MINIKUBE_IP/g		$srcs/nginx/srcs/index.html
sed -i '' s/__SSH_USERNAME__/$SSH_USERNAME/g	$srcs/nginx/srcs/index.html
sed -i '' s/__SSH_PASSWORD__/$SSH_PASSWORD/g	$srcs/nginx/srcs/index.html
sed -i '' s/__FTPS_USERNAME__/$FTPS_USERNAME/g	$srcs/nginx/srcs/index.html
sed -i '' s/__FTPS_PASSWORD__/$FTPS_PASSWORD/g	$srcs/nginx/srcs/index.html

eval $(minikube docker-env)

echo "Creating Persistent Volumes..."
for pv in "${pvs[@]}"
do
	kubectl delete -f pvc $pv-pv-claim >/dev/null 2>&1 # delete yaml
	kubectl delete -f pv $pv-pv-volume >/dev/null 2>&1
	kubectl apply -f $volumes/$pv-pv-volume.yaml > /dev/null # volume and volume claim
	kubectl apply -f $volumes/$pv-pv-claim.yaml > /dev/null
done

# create path for archives if doesn't exist
mkdir -p $dir_archive
## Save and get all customized images in minikube
echo "Building images:"
for service in "${services[@]}"
do
	echo "		Building new image..."
	docker build -t $service-image $srcs/$service > /dev/null # build archive
	if [[ $service == "nginx" ]]
	then
		kubectl delete -f srcs/ingress-deployment.yaml >/dev/null 2>&1
		echo "		Creating ingress for nginx..."
		kubectl apply -f srcs/ingress-deployment.yaml > /dev/null
	fi
	kubectl delete -f srcs/$service-deployment.yaml > /dev/null 2>&1
	echo "		Creating container..."
	kubectl apply -f srcs/$service-deployment.yaml > /dev/null
	while [[ $(kubectl get pods -l app=$service -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]];
	do
		sleep 1;
	done
	sed -i '' s/__$service-POD__/$(kubectl get pods | grep $service | cut -d" " -f1)/g $srcs/grafana/srcs/global.json

done

# sql
kubectl exec -i $(kubectl get pods | grep mysql | cut -d" " -f1) -- mysql -u root -e 'CREATE DATABASE wordpress;' > /dev/null
kubectl exec -i $(kubectl get pods | grep mysql | cut -d" " -f1) -- mysql wordpress -u root < $srcs/wordpress/srcs/wordpress.sql
echo "Database wordpress created !"

# grafana dashboard
kubectl exec -i $(kubectl get pods | grep grafana | cut -d" " -f1) -- /bin/sh -c "cat >> /usr/share/grafana/conf/provisioning/dashboards/global.json" < $srcs/grafana/srcs/global.json > /dev/null 2>&1
echo "Dashboard ok !"


echo "Deleting temporary files..."
rm -f 	$srcs/telegraf.conf \
		$srcs/nginx/srcs/telegraf.conf \
		$srcs/ftps/telegraf.conf \
		$srcs/mysql/srcs/telegraf.conf \
		$srcs/wordpress/srcs/telegraf.conf \
		$srcs/phpmyadmin/srcs/telegraf.conf \
		$srcs/grafana/srcs/telegraf.conf \
		$srcs/nginx/srcs/install.sh \
		$srcs/ftps/srcs/install.sh \
		$srcs/ftps/Dockerfile \
		$srcs/wordpress/srcs/wp-config.php \
		$srcs/mysql/srcs/start.sh \
		$srcs/wordpress/srcs/wordpress.sql \
		$srcs/grafana/srcs/global.json \
		$srcs/nginx/srcs/index.html

echo "✅		ft_services deployment done"
echo "
Minikube IP is : $MINIKUBE_IP - Type 'minikube dashboard' for dashboard
================================================================================
LINKS:
	nginx:			https://$MINIKUBE_IP/ (or http)
	wordpress:		http://$MINIKUBE_IP:5050
	phpmyadmin:		http://$MINIKUBE_IP:5000
	grafana:		http://$MINIKUBE_IP:3000

OTHERS:
	nginx:			ssh admin@$MINIKUBE_IP -p 3022
	ftps:			$MINIKUBE_IP:21

ACCOUNTS:			(username:password)
	ssh:			$SSH_USERNAME:$SSH_PASSWORD (port 3022)
	ftps:			$FTPS_USERNAME:$FTPS_PASSWORD (port 21)
	database:		$DB_USER:$DB_PASSWORD (sql / phpmyadmin)
	grafana:		admin:admin
	influxdb:		root:password (port 8086)
	wordpress:
				admin:admin (Admin)
				lmartin:lmartin (Author)
				norminet:norminet (Subscriber)
				visitor:visitor (Subscriber)

TEST PERSISTENT MYSQL/INFLUXDB:
	kubectl exec -it \$(kubectl get pods | grep mysql | cut -d\" \" -f1) -- /bin/sh -c \"kill 1\"
	kubectl exec -it \$(kubectl get pods | grep influxdb | cut -d\" \" -f1) -- /bin/sh -c \"kill 1\"
"
