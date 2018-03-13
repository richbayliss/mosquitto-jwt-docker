FROM ubuntu:xenial AS builder

WORKDIR /

RUN apt-get update && \
    apt-get install -y build-essential curl libwrap0-dev libssl-dev libc-ares-dev uuid-dev xsltproc docbook-xsl git

ENV VERSION=v1.4.14
ENV DESTDIR=/mosquitto/install

RUN git clone https://github.com/eclipse/mosquitto.git && \
    cd mosquitto && \
    git checkout tags/v1.4.14

WORKDIR /mosquitto

# build mosquitto main server...
RUN make WITH_SRV:=no && \
    mkdir -p ${DESTDIR} && \
    make install

# build the auth plugin...
RUN git clone https://github.com/richbayliss/mosquitto-auth-plug.git && \
    cd mosquitto-auth-plug && \
    git checkout tags/0.1.2

WORKDIR /mosquitto/mosquitto-auth-plug

RUN apt-get install -y libmysqlclient-dev 

RUN cp config.mk.in config.mk && \
    sed -i "s/MOSQUITTO_SRC =/MOSQUITTO_SRC = ..\//" config.mk && \
    make

# download extra tools...
WORKDIR /

RUN mkdir -p /confd/bin && \
    curl -L -o /confd/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.14.0/confd-0.14.0-linux-amd64 && \
    chmod +x /confd/bin/confd

# put the server image together...
FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y libssl1.0.0 libmysqlclient20 && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 1883

VOLUME ["/var/lib/mosquitto", "/etc/mosquitto", "/etc/mosquitto.d"]

WORKDIR /

RUN adduser --shell /bin/false mosquitto && \
    usermod -aG sudo mosquitto

COPY --from=builder /mosquitto/install/ /
COPY --from=builder /mosquitto/mosquitto-auth-plug/auth-plug.so /usr/local/lib/
COPY --from=builder /mosquitto/mosquitto-auth-plug/np /usr/local/bin/
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
