srcs=./srcs

cp $srcs/grafana/srcs/ftpsModel.json			$srcs/grafana/srcs/ftps.json
cp $srcs/grafana/srcs/nginxModel.json			$srcs/grafana/srcs/nginx.json
cp $srcs/grafana/srcs/mysqlModel.json			$srcs/grafana/srcs/mysql.json
cp $srcs/grafana/srcs/phpmyadminModel.json		$srcs/grafana/srcs/phpmyadmin.json
cp $srcs/grafana/srcs/grafanaModel.json			$srcs/grafana/srcs/grafana.json
cp $srcs/grafana/srcs/wordpressModel.json		$srcs/grafana/srcs/wordpress.json
cp $srcs/grafana/srcs/influxdbModel.json		$srcs/grafana/srcs/influxdb.json

services=(nginx ftps wordpress mysql phpmyadmin grafana influxdb)
for service in "${services[@]}"
do
	sed -i s/__$service-POD__/$(kubectl get pods | grep $service | cut -d" " -f1)/g $srcs/grafana/srcs/$service.json
	kubectl exec -i $(kubectl get pods | grep grafana | cut -d" " -f1) -- /bin/sh -c "cat >> /usr/share/grafana/conf/provisioning/dashboards/$service.json" < $srcs/grafana/srcs/$service.json > /dev/null 2>&1
done

