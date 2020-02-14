# 1) Move executable in goinfre folder
if [ -d "/goinfre" ]
then
	mkdir	-p /goinfre/ft_services_root
	export	MINIKUBE_HOME="/goinfre/ft_services_root"
	echo 	$MINIKUBE_HOME
else
	# echo 	No Goinfre Folder
	# exit 	1
	echo
fi

# 2) Start Minikube
if ! minikube status > /dev/null 2>&1
then
    echo Starting Minikube ...
    if ! minikube start --cpus=4 --memory 4000 --disk-size 11000 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000
    then
		echo We failed to launch Minikube
		exit 1
    fi
	minikube addons enable metrics-server
	minikube addons enable ingress
fi


kubectl get all
export MINIKUBE_IP=$(minikube ip)
echo "Minikube IP is $MINIKUBE_IP"
eval $(minikube docker-env)

cp srcs/ftps/entrypoint srcs/ftps/entrypoint-target
sed -i '' "s/##MINIKUBE_IP##/$MINIKUBE_IP/g" srcs/ftps/entrypoint-target

docker build -t ftpss srcs/ftps


docker build -t nginx_test srcs/nginx



eval $(minikube docker-env)

kubectl apply -f srcs/mysql/mysql.yaml
kubectl apply -f srcs/phpmyadmin/phpmyadmin.yaml
kubectl apply -f srcs/nginx/nginx.yaml
kubectl apply -f srcs/wordpress/wordpress.yaml
kubectl apply -f srcs/ftps/ftps.yaml

kubectl apply -k srcs/
kubectl apply -f srcs/ingress/ingress.yaml

helm install -f srcs/influxdb/influxdb.yaml influxdb stable/influxdb
sleep 10s
helm install -f srcs/grafana/grafana.yaml grafana stable/grafana
sleep 10s
helm install -f srcs/telegraf/telegraf.yaml telegraf stable/telegraf

echo "Services installed... Launching dashboard \n"
echo "Wordpress URL is : http://$MINIKUBE_IP:5050 \n"
echo "NGINX URL is : http://$MINIKUBE_IP \n"
echo "PHPMYADMIN URL is : http://$MINIKUBE_IP:5000 \n"

minikube dashboard

# ------------------------------------------------------------------------------

# Explanations
#	--> minikube start : https://evalle.xyz/posts/configure-kube-apiserver-in-minikube/
#		http://www.thinkcode.se/blog/2019/02/20/kubernetes-service-node-port-range

#   --> Eval() : https://stackoverflow.com/questions/52310599/what-does-minikube-docker-env-mean
#	--> retourne un string de shell d'export de plusieurs variables d'environnement pour que le daemon Docker puisse s'exécuter dans minikube
#	--> eval execute ce string correspondant à un script shell
#	--> 2>&1 shell statement : https://stackoverflow.com/a/818284/10830328
#		On test l'output de minikube status, s'il y a un output dans la sortie STDERR (qu'on redirige dans STDOUT - fd 1)
#		(STDERR  = fd = 2) alors on va démarer minikube

#	eval() --> exécuter en shell le string d'output
# 	Pour voir l'output, exécuter juste $ minikube docker-env (sans eval)
