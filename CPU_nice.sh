#!/bin/bash

# Запуск двух процессов с разными значениями nice
echo "Запуск процесса 1 с nice 10"
nice -n 10 bash cpu_intensive_task.sh 1 &

echo "Запуск процесса 2 с nice -10"
nice -n -10 bash cpu_intensive_task.sh 2 &

# Ожидание завершения обоих процессов
wait