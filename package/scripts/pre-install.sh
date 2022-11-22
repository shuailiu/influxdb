#!/bin/bash

DATA_DIR=/var/lib/rtdb
USER=rtdb
GROUP=rtdb
LOG_DIR=/var/log/rtdb

if ! id rtdb &>/dev/null; then
    useradd --system -U -M rtdb -s /bin/false -d $DATA_DIR
fi

# check if DATA_DIR exists
if [ ! -d "$DATA_DIR" ]; then
    mkdir -p $DATA_DIR
    chown $USER:$GROUP $DATA_DIR
fi

# check if LOG_DIR exists
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p $LOG_DIR
    chown $USER:$GROUP $LOG_DIR
fi
