# if [ -d "/goinfre" ]; then
# 	[ -z "${USER}" ] && export USER=`whoami`
# 	mkdir -p /goinfre/$USER && export MINIKUBE_HOME="/goinfre/$USER"
# fi

if [[ $1 == "clean" ]]
then
	if minikube status > /dev/null 2>&1
	then
		echo "Cleaning all Kubectl ressources ..."
		kubectl		delete all --all
		minikube	stop
		minikube	delete
		echo "... Done"
	else
		echo "Minikube isn't running - Nothing to clean"
	fi
fi
