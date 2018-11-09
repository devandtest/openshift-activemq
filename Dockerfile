FROM rhel7.5                     

MAINTAINER Dev and Test <testanddev@example.com>

ENV ACTIVEMQ_VERSION=5.15.7 
ENV POSTGRES_JDBC_DRIVER_VERSION=9.4.1212 
ENV ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV ACTIVEMQ_HOME=/opt/activemq

ENV ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION    

COPY files/docker-entrypoint.sh /docker-entrypoint.sh

# Add java 
RUN yum -y install java-1.8.0-openjdk.x86_64

RUN set -x && \
    curl -s -S https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz | tar xvz -C /opt && \
    ln -s /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    cd $ACTIVEMQ_HOME/lib/optional && \
    curl -O https://jdbc.postgresql.org/download/postgresql-$POSTGRES_JDBC_DRIVER_VERSION.jar && \    
    useradd -r -M -d $ACTIVEMQ_HOME activemq && \
    chown -R :0 /opt/$ACTIVEMQ && \
    chown -h :0 $ACTIVEMQ_HOME && \
    chmod go+rwX -R $ACTIVEMQ_HOME && \
    chmod +x /docker-entrypoint.sh

WORKDIR $ACTIVEMQ_HOME

EXPOSE $ACTIVEMQ_TCP $ACTIVEMQ_AMQP $ACTIVEMQ_STOMP $ACTIVEMQ_MQTT $ACTIVEMQ_WS $ACTIVEMQ_UI

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bin/activemq console"]
