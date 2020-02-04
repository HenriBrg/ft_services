# Prérequis

# 1) --> VirtualBox : Logiciel libre de virtualisation (Oracle)
# 2) --> Docker - Docker Machine
# 3) --> Minikube
# 4) --> Kubctl
# 5) --> Helm

brew		install minikube
minikube	addons enable ingress

if ! minikube start --vm-driver virtualbox
then
	echo We failed to launch Minikube
	exit 1
fi

export		MINIKUBEIP=$(minikube ip)
echo 		"Minikube IP = $MINIKUBEIP"

# Détail de cette commande : https://stackoverflow.com/questions/52310599/what-does-minikube-docker-env-mean
#	--> retourne un string de shell d'export de plusieurs variables d'environnement pour que le daemon Docker puisse s'exécuter dans minikube
#	--> eval execute ce string correspondant à un script shell
# Tips : pour voir l'output, exécuter juste $ minikube docker-env (sans eval)
eval $(minikube docker-env)
