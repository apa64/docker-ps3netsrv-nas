#!/bin/bash
#
# Start ps3netsrv Docker image on Synology DS216j (armada38x armv7l).
# Copy to /usr/local/etc/rc.d/S99ps3netsrv.sh
# Author: @apa64@mementomori.social
NAME=ps3netsrv
DAEMON_ARGS="--config-file=/usr/local/etc/docker/daemon.json --pidfile=$PIDFILE"
LOGFILE=/var/log/$NAME.log
IMAGE=shawly/ps3netsrv:edge-20250126

# Check if docker is installed
if ! command -v docker > /dev/null 2>&1; then
    echo "docker is not installed. Please install Docker." | tee -a $LOGFILE
    exit 1
fi

#echo "Waiting for dockerd to start" | tee -a $LOGFILE
timeout 15 sh -c "until docker info > /dev/null 2>&1 ; do sleep 1 ; done"
if ! docker info > /dev/null 2>&1; then
  echo "ERROR: docker is not running" | tee -a $LOGFILE
  exit 1
fi

# Check if ps3netsrv is running
function is_running() {
    docker inspect -f '{{.State.Running}}' $NAME 2>/dev/null | grep -q "true"
}

case "$1" in
    start)
        if is_running; then
            echo "$NAME is already running" | tee -a $LOGFILE
            exit 1
        fi
        echo "Starting $NAME" | tee -a $LOGFILE
        USER_ID=$(stat -c %u /volume1/data/ps3netsrv)
        GROUP_ID=$(stat -c %g /volume1/data/ps3netsrv)
        # start container detached, clean up on exit, restart on failure, use host network, expose port, mount folder, set user and group id
        docker run -d --rm --restart on-failure:5 --net=host --name=$NAME -p 38008:38008 -v /volume1/data/ps3netsrv:/games:ro -e USER_ID=$USER_ID -e GROUP_ID=$GROUP_ID $IMAGE >> $LOGFILE 2>&1
        rc=$?
        ;;
    stop)
        if is_running; then
            echo "Stopping $NAME" | tee -a $LOGFILE
            docker stop $NAME
            rc=$?
        else
            echo "$NAME is not running" | tee -a $LOGFILE
            rc=1
        fi
        ;;
    status)
        # 2: program of package is dead and /var/lock lock file exists
        # 3: package is not running
        # 150: package is broken and should be reinstalled.
        # 4: package status is unknown
        rc=4
        if is_running; then
            echo "$NAME is running" | tee -a $LOGFILE
            rc=0
        else
            echo "$NAME is not running" | tee -a $LOGFILE
            rc=1
        fi
        ;;
    *)
        echo "Usage: "$1" {start|stop|status}"
        exit 1
esac
exit $rc
