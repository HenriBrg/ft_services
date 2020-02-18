if [ -d "/goinfre" ]; then
	[ -z "${USER}" ] && export USER=`whoami`
	mkdir -p /goinfre/$USER && export MINIKUBE_HOME="/goinfre/$USER"
fi

# export MINIKUBE_HOME="/goinfre/$USER"




SLEEP ENTRE CHAQUE RUN
