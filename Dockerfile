FROM java:openjdk-7-jdk
MAINTAINER Oscar Morante <oscar.morante@mirada.tv>

RUN apt-get update && apt-get install -y \
  libsnappy1 \
  libssl-dev

RUN cp /usr/lib/jvm/java-7-openjdk-amd64/lib/tools.jar /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext

RUN mkdir -p /opt /var/log/drill

ENV HADOOP_VERSION=2.8.0-SNAPSHOT
ENV DRILL_VERSION=1.8.0-SNAPSHOT

# Install Hadoop from local tarball (for the native libs)
ADD hadoop-$HADOOP_VERSION.tar.gz /opt

# Install Drill from local tarball
ADD apache-drill-$DRILL_VERSION.tar.gz /opt

ADD drill-env.sh /opt/apache-drill-$DRILL_VERSION/conf/drill-env.sh
ADD core-site.xml /opt/apache-drill-$DRILL_VERSION/conf/core-site.xml
ADD logback.xml /opt/apache-drill-$DRILL_VERSION/conf/logback.xml

ENV DRILL_LOG_DIR=/var/log/drill
ENV DRILLBIT_LOG_PATH=/var/log/drill/drillbit.log
ENV DRILLBIT_QUERY_LOG_PATH=/var/log/drill/drill-query.log
ENV DRILL_MAX_DIRECT_MEMORY=8G
ENV DRILL_HEAP=4G
ENV DRILL_CLUSTER=drillcluster
ENV DRILL_BUFFER_SIZE=100
ENV S3A_CONNECTION_MAXIMUM=15
ENV S3A_ENDPOINT=s3.amazonaws.com

ENTRYPOINT /opt/apache-drill-$DRILL_VERSION/bin/runbit

EXPOSE 8047
EXPOSE 8048
EXPOSE 31010
EXPOSE 31011
EXPOSE 31012
EXPOSE 46655/udp

