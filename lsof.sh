#!/bin/bash

# Вывод заголовка
printf "%-7s %-10s %-10s %-10s %-s\n" "PID" "USER" "FD" "TYPE" "NAME"

# Выполнение итерации по каждому каталогу PID в /proc
for pid_dir in /proc/[0-9]*; do
    # Извлечь PID из имени директории
    pid=${pid_dir##*/}

    # Проверка, доступен ли каталог процессов
    if [[ ! -r "$pid_dir" ]]; then
        continue
    fi

    # Найти пользователя, которому принадлежит этот процесс
    user=$(stat -c '%U' "$pid_dir")

    # Выполнение итерации по файловым дескрипторам
    for fd in "$pid_dir"/fd/*; do
        if [[ -e "$fd" ]]; then
            # Получить номер файлового дескриптора
            fd_num=$(basename "$fd")

            # Получить тип файла
            type=$(ls -l "$fd" 2>/dev/null | awk '{print $1}')

            # Получить имя файла
            name=$(readlink -f "$fd" 2>/dev/null)

            # Вывод инвормации о процессе
            printf "%-7s %-10s %-10s %-10s %-s\n" "$pid" "$user" "$fd_num" "$type" "$name"
        fi
    done
done 
