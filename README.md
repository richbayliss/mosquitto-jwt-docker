# mosquitto-jwt-docker
Mosquitto MQTT server, with JWT auth backend, running in Docker

# Why?
MQTT is a great protocol for linking embedded microcontrollers to software on the web. Its publish/subscribe model works great for both 
public channels of communications and for private ones. An Access Control List (ACL) is needed to restrict every other client 
from being able to read the messages designated to others. By default, Mosquitto doesn't have this functionality; this project aims to solve that.

# Why Docker?
Running containers is easy and reliable. I belive that the future of services is running inside a container so I set out to make sure 
Mosquitto would run inside a container with the auth-plugin. To build this container you just need Docker installed.

# Building
Simply clone the repo onto your machine, then in the project directory run:

`$ docker build -t mosquitto-server .`

# Running

## Step 1: Run the container
```bash
$ docker run -it -d \
    --name mosquitto \
    -e JWT_SECRET=mySecretHere
    mosquitto-server
```


