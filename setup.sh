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

# • Credentials
SSH_USERNAME=admin
SSH_PASSWORD=admin
FTPS_USERNAME=admin
FTPS_PASSWORD=admin
DB_USER=root
DB_PASSWORD=password

# • Variables
services=(nginx ftps wordpress mysql phpmyadmin grafana influxdb)
pvs=(wp mysql influxdb)

# • Paths
srcs=./srcs
# Mac à 42 : rootPath = /goinfre/$USER
# Mac Home : rootPath = /Users/$USER
rootPath=/Users/$USER
rootDocker=$rootPath/docker
rootMinikube=$rootPath/minikube
rootArchive=$rootPath/images-archives
volumes=$srcs/volumes

if [[ $1 != "update" ]]
then
	which brew > /dev/null
	if [[ $? != 0 ]] ; then
		echo "We need brew to continue. Install it"
		exit 1
	fi

	which kubectl > /dev/null
	if [[ $? != 0 ]] ; then
		echo "We need kubectl to continue. Install it"
		exit 1
	fi

	which minikube > /dev/null
	if [[ $? != 0 ]] ; then
		echo "We need minikube to continue. Install it"
		exit 1
	fi

	mkdir -p $rootMinikube
	ln   -sf $rootMinikube /Users/$USER/.minikube

	# pkill Docker
	# if [ ! -d $rootDocker ]; then
	# 	rm -rf ~/Library/Containers/com.docker.docker ~/.docker
	# 	mkdir -p $rootDocker/{com.docker.docker,.docker}
	# 	ln -sf $rootDocker/com.docker.docker ~/Library/Containers/com.docker.docker
	# 	ln -sf $rootDocker/.docker ~/.docker
	# fi

	which virtualbox > /dev/null
	if [[ $? != 0 ]] ; then
		echo "We need VirtualBox to continue. Install it"
		exit 1
	fi

	docker info > /dev/null 2>&1
	if [[ $? != 0 ]] ; then
		echo "Docker isn't running. Launch Docker to continue"
		exit 1
	fi

	which docker-machine > /dev/null
	if [[ $? != 0 ]] ; then
		echo "We need Docker-Machine to continue. Install it"
		exit 1
	fi

	echo "Cleaning old ft_services resources"
	docker-machine stop > /dev/null
	minikube delete
	echo "Creating new Docker resources"
	# Docker-Machine create une VM (ici via VBox) dans laquel il installe Docker et
	# facilite la coordination entre l'OS et la VM
	docker-machine create --driver virtualbox default > /dev/null
	docker-machine start
	echo "Creating new Minikube resources"
	minikube start --cpus=2 --disk-size 11000 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000
	minikube addons enable dashboard
	minikube addons enable ingress
	minikube addons enable metrics-server
	MINIKUBE_IP=$(minikube ip)
fi

# • On duplique au préalable tous les fichiers sources de configuration

cp $srcs/nginx/srcs/install_model.sh 			$srcs/nginx/srcs/install.sh
cp $srcs/ftps/srcs/install_model.sh 			$srcs/ftps/srcs/install.sh
cp $srcs/ftps/Dockerfile_model					$srcs/ftps/Dockerfile
cp $srcs/wordpress/srcs/wp-config_model.php		$srcs/wordpress/srcs/wp-config.php
cp $srcs/mysql/srcs/start_model.sh				$srcs/mysql/srcs/start.sh
cp $srcs/wordpress/srcs/wordpress_model.sql		$srcs/wordpress/srcs/wordpress.sql
cp $srcs/grafana/srcs/global_model.json			$srcs/grafana/srcs/global.json
cp $srcs/nginx/srcs/index_model.html			$srcs/nginx/srcs/index.html

# • On intègre la configuration Telegraf dans chaque container

cp $srcs/telegraf_model.conf					$srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/nginx/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/ftps/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/mysql/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/wordpress/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/phpmyadmin/srcs/telegraf.conf
cp $srcs/telegraf.conf							$srcs/grafana/srcs/telegraf.conf

# • Après avoir dupliqué, on remplace toutes les variables dans les fichiers de
# 	configuration temporaire

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

# • Export des variables docker/minikube
eval $(minikube docker-env)

# • Création des volumes
for pv in "${pvs[@]}"
do
	# -f take in arguments : type of resource and name of file
	# About pvc / pv : check MustKnow
	kubectl delete -f pvc $pv-pv-claim > /dev/null 2>&1
	kubectl delete -f pv $pv-pv-volume > /dev/null 2>&1
	kubectl apply -f $volumes/$pv-pv-volume.yaml > /dev/null
	kubectl apply -f $volumes/$pv-pv-claim.yaml > /dev/null
done

# • Création des services





# • Création de la DB SQL
