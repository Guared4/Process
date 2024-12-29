#!/bin/bash

# Печать заголовка
printf "%-7s %-12s %-8s %-s\n" "PID" "TTY" "STAT" "COMMAND"

# Итерация по каждому каталогу PID в /proc
for pid in /proc/[0-9]*; do
    # Извлечь PID из имени директории
    pid=${pid##*/}

    # Чтение файла
    stat_file="/proc/$pid/stat"
    if [[ -r "$stat_file" ]]; then
        read pid comm state ppid pgrp session tty_nr tpgid flags minflt cminflt majflt \
            cmajflt utime stime cutime cstime priority nice num_threads itrealvalue \
            starttime vsize rss rsslim startcode endcode startstack kstkesp kstkeip \
            signal blocked sigignore sigcatch wchan nswap cnswap exit_signal processor \
            rt_priority policy delayacct_blkio_ticks guest_time cguest_time \
            start_data end_data start_brk arg_start arg_end env_start env_end exit_code < "$stat_file"

        # Чтение командной строки
        cmdline=$(tr '\0' ' ' < /proc/$pid/cmdline)
        if [[ -z "$cmdline" ]]; then
            cmdline="[$comm]"
        fi

        # Преобразовать номер TTY в человекочитаемый формат
        tty=$(ls -l /proc/$pid/fd/0 2>/dev/null | awk '{print $NF}' | sed 's#/dev/##')
        if [[ -z "$tty" ]]; then
            tty="?"
        fi

        # Печать информации о процессе
        printf "%-7s %-12s %-8s %-s\n" "$pid" "$tty" "$state" "$cmdline"
    fi
done