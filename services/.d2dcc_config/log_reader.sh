#!/bin/bash

set -e

TARGET_LOG_FILE=/data/${NAME}/server.log
touch $TARGET_LOG_FILE
PID_FILE=/var/run/server.pid

log_message() {
    dt=$(date '+%d/%m/%Y %H:%M:%S');
    echo "[ ${dt} ]: $1"
}

copy_file() {
    # Only read the lines not previously read
    local line_prev_copied=$(($(cat $TARGET_LOG_FILE | wc -l) + 1))
    local output=$(ssh $SSH_OPTION root@$NAME "tail -n +$line_prev_copied $SERVER_LOG_FILE")
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

check_pid() {
    ssh $SSH_OPTION root@$NAME "kill -0 \$(cat $PID_FILE) 2>/dev/null"
    local result=$?
    if [ $result -ne 0 ]; then
        log_message "Error: Problem reading the PID file. Is the server running?"
        return $result
    fi
}

fail_count=0
until (( fail_count > 5 )); do
    if ! check_pid || ! copy_file; then
        ((fail_count++))
    fi
    sleep 20
done

log_message "Error: Log Reader failed"
exit 1
