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
    if ! minikube start --cpus=4 --vm-driver virtualbox --extra-config=apiserver.service-node-port-range=1-35000
    then
		echo We failed to launch Minikube
		exit 1
    fi
fi

# 3) Set ENV variables
eval 		$(minikube docker-env)
export		MINIKUBEIP=$(minikube ip)

# 4) Deploy Nginx SQL PhpMyAdmin



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
