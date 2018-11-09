FROM rhel7/rhel

MAINTAINER R&D Mindbox <ran2d@mindboxgroup.com>

ENV ACTIVEMQ_VERSION=5.15.7 
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV ACTIVEMQ_HOME=/opt/activemq
ENV SHA512_VAL=44eea78a871974267de3c9b94e1ac4a6703b9ff6a83e4db3b5338e2df1736c3c9fa716867af3be4ac55f0bdd8df40f2ae3eb96232868878e3e57247738277997
ENV ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION

COPY files/docker-entrypoint.sh /docker-entrypoint.sh

# Download ActiveMQ
RUN curl "https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz" -o $ACTIVEMQ-bin.tar.gz

# Validate checksum
RUN if [ "$SHA512_VAL" != "$(sha512sum $ACTIVEMQ-bin.tar.gz | awk '{print($1)}')" ];\
    then \
        echo "sha512 values doesn't match! exiting."  && \
        exit 1; \
    fi;
    
# Update RHEL
RUN yum -y update

# Install Java
RUN yum -y install java-1.8.0-openjdk.x86_64

RUN tar xzf $ACTIVEMQ-bin.tar.gz -C  /opt && \
    ln -s /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    useradd -r -M -d $ACTIVEMQ_HOME activemq && \
    chown -R activemq:activemq /opt/$ACTIVEMQ && \
    chown -h activemq:activemq $ACTIVEMQ_HOME && \
    chmod +x /docker-entrypoint.sh

USER root

WORKDIR $ACTIVEMQ_HOME
EXPOSE $ACTIVEMQ_TCP $ACTIVEMQ_AMQP $ACTIVEMQ_STOMP $ACTIVEMQ_MQTT $ACTIVEMQ_WS $ACTIVEMQ_UI

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bin/activemq console"]
