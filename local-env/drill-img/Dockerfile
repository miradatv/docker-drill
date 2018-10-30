FROM debian:9.5

ARG DRILL_VERSION=1.14.0

RUN ln -f -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime \
    && apt-get update \
	&& apt-get install -y wget curl htop procps net-tools vim nano \
		openjdk-8-jdk \
	&& cd /tmp \
	&& wget http://apache.mirrors.hoobly.com/drill/drill-${DRILL_VERSION}/apache-drill-${DRILL_VERSION}.tar.gz \
	&& tar -xvf apache-drill-${DRILL_VERSION}.tar.gz \
	&& mv apache-drill-${DRILL_VERSION} /opt/ \
	&& ln -s /opt/apache-drill-${DRILL_VERSION}/bin/sqlline /usr/local/bin/sqlline \
 	&& ln -s /opt/apache-drill-${DRILL_VERSION}/bin/drill-embedded /usr/local/bin/drill-embedded
	
COPY opt/apache-drill/conf/ /opt/apache-drill-${DRILL_VERSION}/conf/

VOLUME ["/drill-data"]

ENTRYPOINT drill-embedded && /bin/bash
