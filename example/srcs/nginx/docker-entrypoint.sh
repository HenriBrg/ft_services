#!/bin/sh
# Execute the CMD from the Dockerfile:
nginx && /usr/sbin/sshd -D
exec "$@"