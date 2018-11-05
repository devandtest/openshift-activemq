FROM rhel7/rhel

MAINTAINER R&D Mindbox <ran2d@mindboxgroup.com>

ENV ACTIVEMQ_VERSION=5.15.7 
ENV POSTGRES_JDBC_DRIVER_VERSION=9.4.1212 
ENV ACTIVEMQ_TCP=61616 
ENV ACTIVEMQ_HOME=/opt/activemq
ENV SHA512_VAL=a1b931a25c513f83f4f712cc126ee67a2b196ea23a243aa6cafe357ea03f721fba6cb566701e5c0e1f2f7ad8954807361364635c45d5069ec2dbf0ba5c6b588b
    
ENV ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION

COPY files/docker-entrypoint.sh /docker-entrypoint.sh

# RHEL update
RUN yum -y update

# Add java
RUN yum -y install java-1.8.0-openjdk.x86_64

RUN set -x && \
    curl -s -S https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz | tar xvz -C /opt && \
    mv /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    cd $ACTIVEMQ_HOME/lib/optional && \
    curl -O https://jdbc.postgresql.org/download/postgresql-$POSTGRES_JDBC_DRIVER_VERSION.jar && \
    useradd -r -M -d $ACTIVEMQ_HOME activemq && \
    chown -R :0 $ACTIVEMQ_HOME && \
    chmod go+rwX -R $ACTIVEMQ_HOME && \
    chmod +x /docker-entrypoint.sh

WORKDIR $ACTIVEMQ_HOME

EXPOSE 61616
EXPOSE 8161

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bin/activemq console"]
