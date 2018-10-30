#!/bin/bash

usage () {
    echo "Usage:"
    echo "    bin/query.sh SQLS-FILE QUERY-TO-EXECUTE"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

if [ -z "$2" ]; then
    usage
fi

SQLS_FILE=$1
QUERY_TO_EXECUTE=$2

TVMETRIX_REPORTS_PATH=/opt/mirada/tvmetrix-reports
TVMETRIX_SQL_PATH=/opt/mirada/tvmetrix-sql

export OPERATORCODE=metrix
export DATAROOTPATH=/metrix/

java -cp $TVMETRIX_REPORTS_PATH/target/uberjar/tvmetrix-reports-0.2.30-standalone.jar:$TVMETRIX_REPORTS_PATH/lib/drill-jdbc-all-1.8.0-SNAPSHOT.jar:$TVMETRIX_REPORTS_PATH/lib/RedshiftJDBC42-1.2.8.1005.jar \
    tvmetrix.reports.core \
    $TVMETRIX_SQL_PATH/platforms/test/config.sql \
    $TVMETRIX_SQL_PATH/$SQLS_FILE \
    --batch -i --date `date "+%Y-%m-%d"` \
    --query $QUERY_TO_EXECUTE


