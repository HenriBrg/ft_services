
# IF RUNNING WITH UBUNTU VM : Mettre le nombre de processeurs minimum à 2
#							  dans le client Virtualbox avant de lancer la VM

# <><><><><><><><><><><><><><><><><> CLEANER <><><><><><><><><><><><><><><><><><

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

# <><><><><><><><><><><><><><><><><> ENV <><><><><><><><><><><><><><><><><><><><

srcs=./srcs
volumes=$srcs/volumes

SSH_USERNAME=admin
SSH_PASSWORD=admin
FTPS_USERNAME=admin
FTPS_PASSWORD=admin
DB_USER=root
DB_PASSWORD=password

services=(nginx ftps wordpress mysql phpmyadmin grafana influxdb)
pvs=(wp mysql influxdb)

# <><><><><><><><><><><><><><><><><> FIRST DEPLOY <><><><><><><><><><><><><><><>

if [[ $1 != "update" ]]
then
		echo
		echo "	NEW CONFIGURATION"
		echo

		# IF Docker refuse to run :
		# 1) sudo usermod -aG docker $(whoami)
		# 2) Clean all and restart the VM

		echo "	DELETE OLD MINIKUBE"
		echo
		minikube delete
		echo
		echo "	START MINIKUBE"
		echo
		if [ $OSTYPE == "linux-gnu" ]
		then
			# UBUNTU VM
			minikube start --vm-driver=docker --extra-config=apiserver.service-node-port-range=1-35000
		else
			# MAC AT HOME
			minikube start --cpus=2 --disk-size 11000 --vm-driver=virtualbox --extra-config=apiserver.service-node-port-range=1-35000
		fi
		minikube addons enable dashboard
		minikube addons enable ingress
		minikube addons enable metrics-server
fi

# <><><><><><><><><><><><><><> FILES CONFIGURATION <><><><><><><><><><><><><><><

MINIKUBE_IP=$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)
echo "MINIKUPE IP = $MINIKUBE_IP"

# REPLACE MODEL FILES

cp $srcs/nginx/srcs/install_model.sh 			$srcs/nginx/srcs/install.sh
cp $srcs/ftps/srcs/install_model.sh 			$srcs/ftps/srcs/install.sh
cp $srcs/ftps/Dockerfile_model					$srcs/ftps/Dockerfile
cp $srcs/wordpress/srcs/wp-config_model.php		$srcs/wordpress/srcs/wp-config.php
cp $srcs/mysql/srcs/start_model.sh				$srcs/mysql/srcs/start.sh
cp $srcs/wordpress/srcs/wordpress_model.sql		$srcs/wordpress/srcs/wordpress.sql
cp $srcs/nginx/srcs/index_model.html			$srcs/nginx/srcs/index.html

cp $srcs/grafana/srcs/ftpsModel.json			$srcs/grafana/srcs/ftps.json
cp $srcs/grafana/srcs/nginxModel.json			$srcs/grafana/srcs/nginx.json
cp $srcs/grafana/srcs/mysqlModel.json			$srcs/grafana/srcs/mysql.json
cp $srcs/grafana/srcs/phpmyadminModel.json		$srcs/grafana/srcs/phpmyadmin.json
cp $srcs/grafana/srcs/grafanaModel.json			$srcs/grafana/srcs/grafana.json
cp $srcs/grafana/srcs/wordpressModel.json		$srcs/grafana/srcs/wordpress.json
cp $srcs/grafana/srcs/influxdbModel.json		$srcs/grafana/srcs/influxdb.json

# ADAPT TELEGRAF

cp $srcs/telegraf_model.conf					$srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/nginx/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/ftps/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/mysql/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/wordpress/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/phpmyadmin/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/grafana/srcs/telegraf.conf

# ADD PASSWORD CONFIG

if [ $OSTYPE == "linux-gnu" ]
then
	# UBUNTU VM
	sed -i s/__SSH_USERNAME__/$SSH_USERNAME/g 	 		$srcs/nginx/srcs/install.sh
	sed -i s/__SSH_PASSWORD__/$SSH_PASSWORD/g 	 		$srcs/nginx/srcs/install.sh
	sed -i s/__FTPS_USERNAME__/$FTPS_USERNAME/g 	 	$srcs/ftps/srcs/install.sh
	sed -i s/__FTPS_PASSWORD__/$FTPS_PASSWORD/g 	 	$srcs/ftps/srcs/install.sh
	sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g 	 		$srcs/ftps/Dockerfile
	sed -i s/__DB_USER__/$DB_USER/g 	 				$srcs/wordpress/srcs/wp-config.php
	sed -i s/__DB_PASSWORD__/$DB_PASSWORD/g 	 		$srcs/wordpress/srcs/wp-config.php
	sed -i s/__DB_USER__/$DB_USER/g 	 				$srcs/mysql/srcs/start.sh
	sed -i s/__DB_PASSWORD__/$DB_PASSWORD/g 	 		$srcs/mysql/srcs/start.sh
	sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g 	 		$srcs/wordpress/srcs/wordpress.sql
	sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g 	 		$srcs/nginx/srcs/index.html
else
	# MAC AT HOME
	sed -i "" s/__SSH_USERNAME__/$SSH_USERNAME/g 	 	$srcs/nginx/srcs/install.sh
	sed -i "" s/__SSH_PASSWORD__/$SSH_PASSWORD/g 	 	$srcs/nginx/srcs/install.sh
	sed -i "" s/__FTPS_USERNAME__/$FTPS_USERNAME/g 	 	$srcs/ftps/srcs/install.sh
	sed -i "" s/__FTPS_PASSWORD__/$FTPS_PASSWORD/g 	 	$srcs/ftps/srcs/install.sh
	sed -i "" s/__MINIKUBE_IP__/$MINIKUBE_IP/g 	 		$srcs/ftps/Dockerfile
	sed -i "" s/__DB_USER__/$DB_USER/g 	 				$srcs/wordpress/srcs/wp-config.php
	sed -i "" s/__DB_PASSWORD__/$DB_PASSWORD/g 	 		$srcs/wordpress/srcs/wp-config.php
	sed -i "" s/__DB_USER__/$DB_USER/g 	 				$srcs/mysql/srcs/start.sh
	sed -i "" s/__DB_PASSWORD__/$DB_PASSWORD/g 	 		$srcs/mysql/srcs/start.sh
	sed -i "" s/__MINIKUBE_IP__/$MINIKUBE_IP/g 	 		$srcs/wordpress/srcs/wordpress.sql
	sed -i "" s/__MINIKUBE_IP__/$MINIKUBE_IP/g 	 		$srcs/nginx/srcs/index.html
fi

# <><><><><><><><><><><> BUILD CONTAINER & APPLY CONFIG <><><><><><><><><><><><>

eval $(minikube docker-env)

for pv in "${pvs[@]}"
do
	echo "Création du volume pour $pv"
	kubectl delete -f pvc $pv-pv-claim >/dev/null 2>&1 # delete yaml
	kubectl delete -f pv $pv-pv-volume >/dev/null 2>&1
	kubectl apply -f $volumes/$pv-pv-volume.yaml > /dev/null # volume and volume claim
	kubectl apply -f $volumes/$pv-pv-claim.yaml > /dev/null
done

for service in "${services[@]}"
do
	echo "Création du container dédié à $service"
	docker build -t $service-image $srcs/$service > /dev/null
	if [[ $service == "nginx" ]]
	then
		kubectl delete -f srcs/ingress-deployment.yaml >/dev/null 2>&1
		echo "Création de l'Ingress pour NGINX"
		kubectl apply -f srcs/ingress-deployment.yaml > /dev/null
	fi
	kubectl delete -f srcs/$service-deployment.yaml > /dev/null 2>&1
	echo "Application de la configuration YAML pour le service $service"
	kubectl apply -f srcs/$service-deployment.yaml > /dev/null
	while [[ $(kubectl get pods -l app=$service -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]];
	do
		time=$(date +%s | bc)
		chrono=$(($time % 10))
		if [ $chrono == "0" ]; then
			printf "."
		fi
		sleep 1
	done
done

echo
echo "Ajout de la DB SQL connectée à Wordpress"
kubectl exec -i $(kubectl get pods | grep mysql | cut -d" " -f1) -- mysql -u root -e 'CREATE DATABASE wordpress;' > /dev/null
echo "Création des tables SQL de Wordpress"
kubectl exec -i $(kubectl get pods | grep mysql | cut -d" " -f1) -- mysql wordpress -u root < $srcs/wordpress/srcs/wordpress.sql

for service in "${services[@]}"
do
	if [ $OSTYPE == "linux-gnu" ]
	then
		sed -i s/__$service-POD__/$(kubectl get pods | grep $service | cut -d" " -f1)/g $srcs/grafana/srcs/$service.json
	else
		sed -i "" s/__$service-POD__/$(kubectl get pods | grep $service | cut -d" " -f1)/g $srcs/grafana/srcs/$service.json
	fi
	kubectl exec -i $(kubectl get pods | grep grafana | cut -d" " -f1) -- /bin/sh -c "cat >> /usr/share/grafana/conf/provisioning/dashboards/$service.json" < $srcs/grafana/srcs/$service.json > /dev/null 2>&1
done


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
		$srcs/grafana/srcs/ftps.json \
		$srcs/grafana/srcs/nginx.json \
		$srcs/grafana/srcs/mysql.json \
		$srcs/grafana/srcs/phpmyadmin.json \
		$srcs/grafana/srcs/grafana.json \
		$srcs/grafana/srcs/wordpress.json \
		$srcs/grafana/srcs/influxdb.json \
		$srcs/nginx/srcs/index.html

# <><><><><><><><><><><><><><><><><><> DONE ! <><><><><><><><><><><><><><><><><>


echo "
MINIKUBE IP		: $MINIKUBE_IP
NGINX			: https://$MINIKUBE_IP
WORDPRESS		: http://$MINIKUBE_IP:5050
NGNINX SSH		: https://$MINIKUBE_IP:443
PHPMYADMIN		: http://$MINIKUBE_IP:5000
GRAFANA			: http://$MINIKUBE_IP:3000

SSH				: admin admin
FTPS			: admin admin
SQL/PHPMYADMIN	: root  password
INFLUXDB		: root  password
WORDPRESS		: admin admin
"
