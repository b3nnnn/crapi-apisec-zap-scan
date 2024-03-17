#!/bin/sh
echo "starting up.."
TARGET_URL=https://apisec.sales-demo.f5demos.com/
mkdir /tmp/tor
mkdir /tmp/log
touch /tmp/log/tor.log
touch /tmp/log/privoxy.log

/usr/bin/tor --quiet -f /etc/tor/torrc
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start tor process: $status"
  exit $status
fi
curl -s -o /dev/null -f --connect-timeout 10 --retry 5 \
    --socks5-hostname localhost:9150 $TARGET_URL || exit 1
echo "tor started and check succeeded."

/usr/sbin/privoxy /tmp/privoxy/config
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start proxy process: $status"
  exit $status
fi
curl -s -o /dev/null -f --connect-timeout 10 --retry 5 \
    -x "http://localhost:8118" $TARGET_URL || exit 1
echo "proxy started and check suceeded."

# Do the scan
zap-api-scan.py -z "-config network.connection.httpProxy.port=8118 -config network.connection.httpProxy.host=localhost -config network.connection.httpProxy.enabled=true" -t /zap/swagger.json -f openapi
sleep infinity
