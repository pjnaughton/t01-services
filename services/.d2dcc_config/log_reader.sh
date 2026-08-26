#!/bin/bash

mkdir -p /data/$NAME
LOG_STORE=/data/$NAME/server.log
touch $LOG_STORE

PID_FILE=/var/run/server.pid

exec_ssh_command() {
    local hostname=$NAME
    local command="$1"
    # Skip the lines for expect lines
    expect << EOF | tr -d '\r' | tail -n +3
        set timeout 10
        spawn ssh root@$hostname "${command}"
        expect {
            "password" {
                send "root\r"
                exp_continue
            }
            eof {
                    # Capture the exit status of the spawned SSH process
                    catch wait result
                    exit [lindex \$result 3]
                }
        }
EOF
}

copy_file() {
    # Only read the lines not previously read
    local line_prev_copied=$(($(cat $LOG_STORE | wc -l) + 1))
    local output=$(exec_ssh_command "tail -n +$line_prev_copied $SERVER_LOG_FILE")
    local result=$?
    if [ $result -ne 0 ]; then
        echo "Failed to read log file"
    else
        # Don't append if there is nothing new in the logfile
        # Will append a newline to local logfile
        [[ -n ${output} ]] && 
            echo "$output" >> $LOG_STORE
    fi
    return $result
}

check_pid() {
    exec_ssh_command "kill -0 \\\$(cat $PID_FILE) 2>/dev/null"
    local result=$?
    if [ $result -ne 0 ]; then
        echo "Problem reading the PID file. Is the server running?"
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

echo "Server not running" >&2
exit 1


     
