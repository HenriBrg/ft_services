EXIT_CODE=1
while [ $EXIT_CODE -gt 0 ]
do
	ps | grep -v grep | grep sshd
	EXIT_CODE=$?
	if [ $EXIT_CODE -gt 0 ]
	then
		:
	else
		/etc/init.d/sshd restart # > /dev/null 2>&1
	fi
	sleep 5
	EXIT_CODE=1
done
