EXIT_CODE=1
while [ $EXIT_CODE -gt 0 ]
do
	ps | grep -v grep | grep sshd
	EXIT_CODE=$?
	if [ $EXIT_CODE -eq 0 ]
	then
		echo "SSH OK"
	else
		echo "SSH KO"
		/etc/init.d/sshd restart > /dev/null 2>&1
	fi
	sleep 5
	EXIT_CODE=1 # Par précaution
done

# Avec le package openssh, le processus lancé s'appelle "sshd"
# On recherche le processus sshd en excluant le processus grep de recherche lui même via -v
