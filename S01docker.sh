#!/bin/sh
#
# Start docker daemon on Synology DS216j (armada38x armv7l).
# Copy to /usr/local/etc/rc.d/01docker.sh
# Author: @apa64@mementomori.social
NAME=dockerd
PIDFILE=/var/run/$NAME.pid
DAEMON_ARGS="--config-file=/usr/local/etc/docker/daemon.json --pidfile=$PIDFILE"
LOGFILE=/var/log/$NAME.log

# Check if dockerd is installed
if ! command -v dockerd > /dev/null 2>&1; then
    echo "dockerd is not installed. Please install Docker." | tee -a $LOGFILE
    exit 1
fi

case "$1" in
    start)
        if [ -e $PIDFILE ]
        then
            ps -p "$(cat $PIDFILE)" > /dev/null 2>&1
            rc=$?
            if [ $rc -eq 0 ]
            then
                echo "$NAME is already running" | tee -a $LOGFILE
                exit 1
            else
                # 1: program of package is dead and /var/run pid file exists.
                echo "$NAME is not running, removing stale $PIDFILE" | tee -a $LOGFILE
                rm $PIDFILE
            fi
        fi
        echo "Starting $NAME" | tee -a $LOGFILE
        # ulimit -n 4096  # needed for influxdb (uncomment if your limit is lower)
        /usr/local/bin/dockerd $DAEMON_ARGS >> $LOGFILE 2>&1 &
        rc=$?
        ;;
    stop)
        if [ -e $PIDFILE ]
        then
            echo "Stopping $NAME" | tee -a $LOGFILE
            kill $(cat $PIDFILE)
            rc=$?
        else
            echo "$PIDFILE does not exist" | tee -a $LOGFILE
            rc=1
        fi
        ;;
    status)
        # 2: program of package is dead and /var/lock lock file exists
        # 3: package is not running
        # 150: package is broken and should be reinstalled.
        # 4: package status is unknown
        rc=4
        if [ -e $PIDFILE ]; then
          ps -p "$(cat $PIDFILE)" > /dev/null 2>&1
          rc=$?
          if [ $rc -eq 0 ]; then
            # 0: package is running.
            echo "$NAME is running" | tee -a $LOGFILE
            rc=0
          else
            # 1: program of package is dead and /var/run pid file exists.
            echo "$NAME is not running" | tee -a $LOGFILE
            rc=1
          fi
        else
            echo "$PIDFILE does not exist" | tee -a $LOGFILE
            rc=4
        fi
        ;;
    *)
        echo "Usage: "$1" {start|stop|status}"
        exit 1
esac
exit $rc
