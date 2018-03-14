FROM ubuntu:xenial AS builder

WORKDIR /

RUN apt-get update && \
    apt-get install -y build-essential curl libwrap0-dev libssl-dev libc-ares-dev uuid-dev xsltproc docbook-xsl git software-properties-common

ENV VERSION=v1.4.14
ENV DESTDIR=/mosquitto/install

# download extra tools...
WORKDIR /

RUN mkdir -p /confd/bin && \
    curl -L -o /confd/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.14.0/confd-0.14.0-linux-amd64 && \
    chmod +x /confd/bin/confd

RUN git clone https://github.com/eclipse/mosquitto.git && \
    cd mosquitto && \
    git checkout tags/v1.4.14

WORKDIR /mosquitto

# build mosquitto main server...
RUN make WITH_SRV:=no && \
    mkdir -p ${DESTDIR} && \
    make install

# build the auth plugin...
RUN add-apt-repository ppa:ben-collins/libjwt \
    && apt-get update \
    && apt-get install -y libjwt-dev

COPY mosquitto-jwt-auth-plug /mosquitto/mosquitto-auth-plug
WORKDIR /mosquitto/mosquitto-auth-plug

RUN sed -i "s/MOSQUITTO_SRC =/MOSQUITTO_SRC = ..\//" config.mk && \
    make

# put the server image together...
FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y libssl1.0.0 software-properties-common && \
    add-apt-repository ppa:ben-collins/libjwt \
    && apt-get update \
    && apt-get install -y libjwt0 \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 1883

VOLUME ["/var/lib/mosquitto", "/etc/mosquitto", "/etc/mosquitto.d"]

WORKDIR /

RUN adduser --shell /bin/false mosquitto && \
    usermod -aG sudo mosquitto

COPY --from=builder /mosquitto/install/ /
COPY --from=builder /mosquitto/mosquitto-auth-plug/mosquitto_auth_plugin_jwt.so /usr/local/lib/
# COPY --from=builder /mosquitto/mosquitto-auth-plug/np /usr/local/bin/
COPY --from=builder /confd/bin/confd /usr/local/bin/
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY *.toml /etc/confd/conf.d/
COPY *.tmpl /etc/confd/templates/
COPY run.sh .
COPY schema.sql /etc/mosquitto/

RUN mkdir -p /etc/confd/templates/ && mkdir -p /etc/confd/conf.d/

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["mosquitto"]
