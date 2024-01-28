#!/bin/bash
. /opt/netrig/lib/config.sh

RADIO="radio0"

[ ! -z ${UID} ] && SUDO=sudo

# Stopping fcgi
$SUDO /opt/netrig/init.d/fcgi-perl stop

if [ ! -f /opt/netrig/run/nginx.pid ]; then
   echo "* No run/nginx.pid or nginx not running!"
   ps auwwx | grep nginx | egrep -v '(grep|joe|vi|emacs)'
fi

PID=$(cat /opt/netrig/run/nginx.pid)

if [ -z "${PID}" ]; then
   echo "* It appears nginx isn't running (empty pid file)"
   rm /opt/netrig/run/nginx.pid
fi
echo "Stopping nginx service..."
echo "Sending SIGTERM..."
$SUDO kill -TERM ${PID}
sleep 3
echo "Sending SIGKILL..."
$SUDO kill -KILL ${PID}
$SUDO rm -f /opt/netrig/run/nginx.pid

PID=$(cat /opt/netrig/run/rigctl-wrapper.pid)
echo "Stopping rigctl-wrapper service..."
echo "Sending SIGTERM..."
$SUDO kill -TERM ${PID}
sleep 3
echo "Sending SIGKILL..."
$SUDO kill -KILL ${PID}
$SUDO rm -f /opt/netrig/run/rigctl-wrapper.pid

echo "stopping asterisk..."
$SUDO /opt/netrig/init.d/asterisk stop

echo "stopping ari..."
#$SUDO /opt/netrig/init.d/netrig-ari stop

echo "stopping rigctld..."
#$SUDO /opt/netrig/init.d/rigctld stop
killall -9 rigctld
echo "Done!"

PREFIX=/opt/netrig/run
# rigctld websocket wrapper
if [ -f "${PREFIX}/rigctl-wrapper.${RADIO}" ]; then
  PID=$(cat "${PREFIX}/rigctl-wrapper.${RADIO}.pid")
  kill -9 ${PID}
  rm -f ${PREFIX}/rigctl-wrapper.${RADIO}.pid
fi

# rigctld
if [ -f "${PREFIX}/rigctld.${RADIO}" ]; then
  PID=$(cat "${PREFIX}/rigctld.${RADIO}.pid")
  kill -9 ${PID}
  rm -f ${PREFIX}/rigctld.${RADIO}.pid
fi
