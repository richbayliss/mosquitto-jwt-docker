# mosquitto-mysql-docker
Mosquitto MQTT server, with MySQL auth backend, running in Docker

# Why?
MQTT is a great protocol for linking embedded microcontrollers to software on the web. Its publish/subscribe model works great for both 
public channels of communications and for private ones. An Access Control List (ACL) is needed to restrict every other client 
from being able to read the messages designated to others. By default, Mosquitto doesn't have this functionality; but luckily a project
is available to create a plugin to provide this kind of authentication and ACL system.

This project is an amalgamation of the Mosquitto and auth-plugin projects.

# Why Docker?
Running containers is easy and reliable. I belive that the future of services is running inside a container so I set out to make sure 
Mosquitto would run inside a container with the auth-plugin. To build this container you just need Docker installed.

# Building
Simply clone the repo onto your machine, then in the project directory run:

`$ docker build -t mosquitto-server .`

# Running

## Step 1: Create the MySQL database
On your MySQL database, run the `scheme.sql`.

## Step 2: Run the container
```bash
$ docker run -it -d \
    --name mosquitto \
    -e MYSQL_HOST={IP/DNS of MySQL server}
    -e MYSQL_USER={username}
    -e MYSQL_PASS={password}
    -e MYSQL_DATABASE={name of database with the schema}
    mosquitto-server
```


