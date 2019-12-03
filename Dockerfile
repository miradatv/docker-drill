FROM debian:9.5

ARG DRILL_VERSION=1.16.0
ARG ALLUXIO_CLIENT_VERSION=1.8.1
ARG MIRADA_UDF_VERSION

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

RUN cd /tmp && \
	wget --no-check-certificate https://downloads.alluxio.io/downloads/files/${ALLUXIO_CLIENT_VERSION}/alluxio-${ALLUXIO_CLIENT_VERSION}-bin.tar.gz && \
	tar -xvf alluxio-${ALLUXIO_CLIENT_VERSION}-bin.tar.gz && \
	cp alluxio-${ALLUXIO_CLIENT_VERSION}/client/alluxio-${ALLUXIO_CLIENT_VERSION}-client.jar /opt/apache-drill-${DRILL_VERSION}/jars/classb

RUN mkdir -p /opt /var/log/drill

ENV DRILL_VERSION=${DRILL_VERSION}
ENV ALLUXIO_CLIENT_VERSION=${ALLUXIO_CLIENT_VERSION}
ENV MIRADA_UDF_VERSION=${MIRADA_UDF_VERSION}

WORKDIR /opt/apache-drill-${DRILL_VERSION}

ADD drill-env.sh /opt/apache-drill-$DRILL_VERSION/conf/drill-env.sh
ADD core-site.xml /opt/apache-drill-$DRILL_VERSION/conf/core-site.xml
ADD logback.xml /opt/apache-drill-$DRILL_VERSION/conf/logback.xml

# Add Mirada's user defined functions
COPY tvmetrix-drill-udf-$MIRADA_UDF_VERSION.jar /opt/apache-drill-$DRILL_VERSION/jars/3rdparty/
COPY tvmetrix-drill-udf-$MIRADA_UDF_VERSION-sources.jar /opt/apache-drill-$DRILL_VERSION/jars/3rdparty/

ENV DRILL_LOG_DIR=/var/log/drill
ENV DRILLBIT_LOG_PATH=/var/log/drill/drillbit.log
ENV DRILLBIT_QUERY_LOG_PATH=/var/log/drill/drill-query.log
ENV DRILL_MAX_DIRECT_MEMORY=8G
ENV DRILL_HEAP=4G
ENV DRILL_CLUSTER=drillcluster
ENV S3A_CONNECTION_MAXIMUM=15
ENV S3A_ENDPOINT=s3.amazonaws.com

EXPOSE 8047 8048 31010 31011 31012 46655/udp

ENTRYPOINT /opt/apache-drill-$DRILL_VERSION/bin/drillbit.sh run
