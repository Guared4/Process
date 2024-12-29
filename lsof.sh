#!/bin/bash

# Print the header
printf "%-7s %-10s %-10s %-10s %-s\n" "PID" "USER" "FD" "TYPE" "NAME"

# Iterate over each PID directory in /proc
for pid_dir in /proc/[0-9]*; do
    # Extract the PID from the directory name
    pid=${pid_dir##*/}

    # Check if the process directory is accessible
    if [[ ! -r "$pid_dir" ]]; then
        continue
    fi

    # Get the user who owns the process
    user=$(stat -c '%U' "$pid_dir")

    # Iterate over the file descriptors
    for fd in "$pid_dir"/fd/*; do
        if [[ -e "$fd" ]]; then
            # Get the file descriptor number
            fd_num=$(basename "$fd")

            # Get the type of the file
            type=$(ls -l "$fd" 2>/dev/null | awk '{print $1}')

            # Get the file name
            name=$(readlink -f "$fd" 2>/dev/null)

            # Print the process info
            printf "%-7s %-10s %-10s %-10s %-s\n" "$pid" "$user" "$fd_num" "$type" "$name"
        fi
    done
done