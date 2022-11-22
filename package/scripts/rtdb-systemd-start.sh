#!/bin/bash -e

ulimit -n 65536
/usr/bin/rtdb >>/var/log/rtdb/rtdb.log  2>>/var/log/rtdb/rtdb.log &
PID=$!
echo $PID > /var/lib/rtdb/rtdb.pid

set +e
attempts=0
url="http://localhost:8086/ready"
result=$(curl -k -s -o /dev/null $url -w %{http_code})
while [ "${result:0:2}" != "20" ] && [ "${result:0:2}" != "40" ]; do
  attempts=$(($attempts+1))
  echo "RTDB API at $url unavailable after $attempts attempts..."
  sleep 1
  result=$(curl -k -s -o /dev/null $url -w %{http_code})
done
echo "RTDB started"
set -e
