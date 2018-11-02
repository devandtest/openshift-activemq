FROM registry.access.redhat.com/rhel7/rhel

MAINTAINER  Krzysztof Korzela <krzysztof.korzela@mindboxgroup.com>

ENV ACTIVEMQ_VERSION=5.15.7 \
    POSTGRES_JDBC_DRIVER_VERSION=9.4.1212 \
    ACTIVEMQ_TCP=61616 \
    ACTIVEMQ_HOME=/opt/amq/activemq

ENV ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION
Dev
COPY files/docker-entrypoint.sh /docker-entrypoint.sh

# Add java
RUN yum -y install java-1.8.0-openjdk.x86_64

RUN set -x && \
    curl -s -S https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz | tar xvz -C /opt/amq && \
    ln -s /opt/amq/$ACTIVEMQ $ACTIVEMQ_HOME && \
    cd $ACTIVEMQ_HOME/lib/optional && \
    curl -O https://jdbc.postgresql.org/download/postgresql-$POSTGRES_JDBC_DRIVER_VERSION.jar && \
    useradd -r -M -d $ACTIVEMQ_HOME activemq && \
    chown -R :0 /opt/amq/$ACTIVEMQ && \
    chown -h :0 $ACTIVEMQ_HOME && \
    chmod go+rwX -R $ACTIVEMQ_HOME && \
    chmod +x /docker-entrypoint.sh

WORKDIR $ACTIVEMQ_HOME

EXPOSE 61616
EXPOSE 8161

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bin/activemq console"]
