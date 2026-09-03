#!/bin/bash

set +x

TARGET_LOG_FILE=/tmp/server.log
touch $TARGET_LOG_FILE
PID_FILE=/var/run/server.pid

log_message() {
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    echo "[ ${dt} ]: $1"
}

copy_file() {
    # Only read the lines not previously read
    local line_prev_copied=$(($(cat $TARGET_LOG_FILE | wc -l) + 1))
    local output=$(send_ssh_command "tail -n +$line_prev_copied $SERVER_LOG_FILE")
    local result=$?
    if [ $result -ne 0 ]; then
        log_message "Error: Failed to read log file"
    else
        # Don't append if there is nothing new in the logfile
        # Will append a newline to local logfile otherwise
        [[ -n ${output} ]] &&
            log_message "$output"
            echo "$output" >> $TARGET_LOG_FILE
    fi
    return $result
}

while true; do
    copy_file
    sleep 5
done
