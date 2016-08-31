export DRILL_BUFFER_SIZE=${DRILL_BUFFER_SIZE:=100}
export DRILL_LOG_LEVEL=${DRILL_LOG_LEVEL:=info}
export DRILL_JAVA_LIB_PATH="/opt/hadoop-$HADOOP_VERSION/lib/native"

env | grep -E "ZOOKEEPER|DRILL|S3A"

drill_conf=/opt/apache-drill-$DRILL_VERSION/conf

# S3A Config
if [ -d /etc/aws-credentials ]; then
  sed -i "s|S3A_ACCESS_KEY|$(cat /etc/aws-credentials/key)|" \
    $drill_conf/core-site.xml
  sed -i "s|S3A_SECRET_KEY|$(cat /etc/aws-credentials/secret)|" \
    $drill_conf/core-site.xml
fi

sed -i "s|S3A_CONNECTION_MAXIMUM|$S3A_CONNECTION_MAXIMUM|" $drill_conf/core-site.xml
sed -i "s|S3A_ENDPOINT|$S3A_ENDPOINT|" $drill_conf/core-site.xml
sed -i "s|DRILL_LOG_LEVEL|$DRILL_LOG_LEVEL|" $drill_conf/logback.xml

# Drill overrides
drill_override_conf=$drill_conf/drill-override.conf
echo "drill.exec.cluster-id: \"$DRILL_CLUSTER\"" > $drill_override_conf
echo "drill.exec.zk.connect: \"$ZOOKEEPER\"" >> $drill_override_conf
echo "drill.exec.buffer.size: $DRILL_BUFFER_SIZE" >> $drill_override_conf

