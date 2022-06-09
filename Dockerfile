FROM debian:11

MAINTAINER mbagdasaryan

ENV TZ=Europe/Moscow

RUN apt update -y && apt install -y nano curl htop  openjdk-11-jdk net-tools
COPY apache-*.tar.gz postgresql*.jar /tmp/
RUN groupadd -g 1000 activemq &&\
    useradd -m -u 1000 -g 1000 activemq  &&\
    mkdir -p /d01/ &&\
    tar -zxf /tmp/apache-activemq*.tar.gz -C /d01 &&\
    ln -s /d01/apache-activemq* /d01/activemq &&\
    sed -i -r "s/127.0.0.1/0.0.0.0/g" /d01/activemq/conf/jetty.xml &&\
    echo "admin: T0m_KaT, admin" >  /d01/activemq/conf/jetty-realm.properties &&\
    echo "zabbix readonly" >  /d01/activemq/conf/jmx.access &&\
    echo "zabbix zabbix" >  /d01/activemq/conf/jmx.password &&\
    chmod 0600 /d01/activemq/conf/jmx.access &&\
    chmod 0600 /d01/activemq/conf/jmx.password  &&\
    sed -i -r 's+ACTIVEMQ_SUNJMX_START="\$ACTIVEMQ_SUNJMX_START -Dcom.sun.management.jmxremote"+ACTIVEMQ_SUNJMX_START="$ACTIVEMQ_SUNJMX_START \
 -Dcom.sun.management.jmxremote=true \
 -Dcom.sun.management.jmxremote.port=9010 \
 -Dcom.sun.management.jmxremote.rmi.port=9011 \
 -Dcom.sun.management.jmxremote.local.only=false \
 -Dcom.sun.management.jmxremote.password.file=${ACTIVEMQ_BASE}/conf/jmx.password \
 -Dcom.sun.management.jmxremote.access.file=${ACTIVEMQ_BASE}/conf/jmx.access \
 -Dcom.sun.management.jmxremote.ssl=false\
 -Djava.rmi.server.hostname=XXX.XXX.XXX.XXX "+g' /d01/activemq/bin/env &&\
    rm -f /tmp/apache-activemq*.tar.gz &&\
    mv /tmp/postgresql*.jar /d01/activemq/lib/ &&\
    chown -R activemq. /d01

USER activemq

CMD /d01/activemq/bin/activemq console 
