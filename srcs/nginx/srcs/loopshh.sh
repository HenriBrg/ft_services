EXIT_CODE=1
while [ $EXIT_CODE -gt 0 ]
do
	ps | grep -v grep | grep sshd
	EXIT_CODE=$?
	if [ $EXIT_CODE -eq 0 ]
	then
		echo "OK - Le serveur SSH tourne bien"
		EXIT_CODE=0 # Par précaution
	else
		 echo "KO - Le serveur SSH ne tourne pas - On le relance"
		EXIT_CODE=1 # Par précaution
	fi
	sleep 10
done

# Avec le package openssh, le processus lancé s'appelle "sshd"
# On recherche le processus sshd en excluant le processus grep de recherche lui même via -v
# openrc; rc-update add sshd
