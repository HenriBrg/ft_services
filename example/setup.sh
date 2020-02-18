if ! minikube status >/dev/null 2>&1
then
    echo Minikube is not started! Starting now...
    if ! minikube start --cpus=4 --memory 4000 --disk-size 11000 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000
    then
        echo Cannot start minikube!
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

docker build -t nginx_test srcs/nginx
docker build -t ftpss srcs/ftps

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