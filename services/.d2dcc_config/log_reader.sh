#!/bin/bash

mkdir -p /data/$NAME
LOG_STORE=/data/$NAME/server.log
touch $LOG_STORE
PID_FILE=/var/run/server.pid

log_message() {
    echo "$1" >> $LOG_STORE
}

copy_file() {
    # Only read the lines not previously read
    local line_prev_copied=$(($(cat $LOG_STORE | wc -l) + 1))
    local output=$(ssh $SSH_OPTION root@$NAME "tail -n +$line_prev_copied $SERVER_LOG_FILE")
    local result=$?
    if [ $result -ne 0 ]; then
        log_message "Failed to read log file"
    else
        # Don't append if there is nothing new in the logfile
        # Will append a newline to local logfile
        [[ -n ${output} ]] &&
            log_message "$output"
    fi
    return $result
}

check_pid() {
    ssh $SSH_OPTION root@$NAME "kill -0 \$(cat $PID_FILE) 2>/dev/null"
    local result=$?
    if [ $result -ne 0 ]; then
        log_message "Problem reading the PID file. Is the server running?"
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

log_message "Log Reader failed"
exit 1
