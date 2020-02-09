# if [ -d "/goinfre" ]
# then
# 	mkdir	-p /goinfre/ft_services_root
# 	export	MINIKUBE_HOME="/goinfre/ft_services_root"
# 	echo 	$MINIKUBE_HOME
# else
# 	echo 	No Goinfre Folder
# 	exit 	1
# fi

if ! minikube status > /dev/null 2>&1
then
    echo Starting Minikube ...
    if ! minikube start --cpus=4 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000
    then
		echo We failed to launch Minikube
		exit 1
    fi
    minikube addons enable metrics-server
    minikube addons enable ingress
	minikube addons enable dashboard
fi

export		MINIKUBE_IP=$(minikube ip)
echo 		"Minikube IP is : $MINIKUBE_IP"

eval 		$(minikube docker-env)

cp			srcs/ftps/ftpsStart srcs/ftps/ftpsStartIPUpdated
sed			-i '' "s/<TO_BE_REPLACE_BY_MINIKUBE_IP>/$MINIKUBE_IP/g" srcs/ftps/ftpsStartIPUpdated

docker		build -t serverftps srcs/ftps # > /dev/null

# ------------------------------------------------------------------------------

# Explanations

#   --> Eval() : https://stackoverflow.com/questions/52310599/what-does-minikube-docker-env-mean
#	--> retourne un string de shell d'export de plusieurs variables d'environnement pour que le daemon Docker puisse s'exécuter dans minikube
#	--> eval execute ce string correspondant à un script shell
#	--> 2>&1 shell statement : https://stackoverflow.com/a/818284/10830328
#		On test l'output de minikube status, s'il y a un output dans la sortie STDERR (qu'on redirige dans STDOUT - fd 1)
#		(STDERR  = fd = 2) alors on va démarer minikube

#	eval() --> exécuter en shell le string d'output
# 	Pour voir l'output, exécuter juste $ minikube docker-env (sans eval)
