#!/bin/sh
set -e

chown mosquitto:mosquitto -R /var/lib/mosquitto

if [ "$1" = 'mosquitto' ]; then
	
    # sensible defaults
    export JWT_SECRET=${JWT_SECRET:-secret}

    /usr/local/bin/confd -onetime -backend env
	exec /usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
fi

exec "$@"
