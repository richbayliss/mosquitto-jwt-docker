#!/bin/sh
set -e

chown mosquitto:mosquitto -R /var/lib/mosquitto

if [ "$1" = 'mosquitto' ]; then
	
    # sensible defaults
    export MYSQL_PORT=${MYSQL_PORT:-3306}
    export MQTT_ANON_USER=${MQTT_ANON_USER:-guest}

    # enable MySQL auth if the container is configured for it...
    if [ -n "$MYSQL_HOST" ] && [ -n "$MYSQL_DATABASE" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASS" ]; then
        echo "Ready to use MySQL for authentication..."
        
        /usr/local/bin/confd -onetime -backend env
    fi

	exec /usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
fi

exec "$@"