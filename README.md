# Process
## Цель домашнего задания работа с процессами
### Описание домашнего задания

Задания на выбор:

- написать свою реализацию ps ax используя анализ /proc
- Результат ДЗ - рабочий скрипт который можно запустить
- написать свою реализацию lsof
- Результат ДЗ - рабочий скрипт который можно запустить
#- дописать обработчики сигналов в прилагаемом скрипте, оттестировать, приложить сам скрипт, инструкции по использованию
#- Результат ДЗ - рабочий скрипт который можно запустить + инструкция по использованию и лог консоли
#- реализовать 2 конкурирующих процесса по IO. пробовать запустить с разными ionice
#- Результат ДЗ - скрипт запускающий 2 процесса с разными ionice, замеряющий время выполнения и лог консоли
- реализовать 2 конкурирующих процесса по CPU. пробовать запустить с разными nice
- Результат ДЗ - скрипт запускающий 2 процесса с разными nice и замеряющий время выполнения и лог консоли
  
1. Для реализации команды ps ax с использованием анализа файловой системы /proc, необходимо написать скрипт на Bash, который будет считывать информацию о процессах из каталога /proc:

Пример скрипта ps_ax.sh:

```bash
#!/bin/bash

# Вывод заголовка
printf "%-7s %-12s %-8s %-s\n" "PID" "TTY" "STAT" "COMMAND"

# Выполнение итерации по каждому каталогу PID в /proc
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

        # Вывод информации о процессе
        printf "%-7s %-12s %-8s %-s\n" "$pid" "$tty" "$state" "$cmdline"
    fi
done  
```

2. Реализовать lsof на Bash, можно используя информацию из /proc файловой системы. Необходимо перебрать все процессы и вывести информацию о файлах, которые они открыли.

Пример скрипта lsof.sh:

```bash
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
```

3. Реализация 2х конкурирующих процессов по CPU. 

Пример скрипта CPU_nice.sh:

```bash
#!/bin/bash

# Запуск двух процессов с разными значениями nice
echo "Запуск процесса 1 с nice 10"
nice -n 10 bash cpu_intensive_task.sh 1 &

echo "Запуск процесса 2 с nice -10"
nice -n -10 bash cpu_intensive_task.sh 2 &

# Ожидание завершения обоих процессов
wait  
```

Инструкции по использованию:

После создания скрипта сделать его исполняемым:

chmod +x CPU_nice.sh  

Запуск скрипта:

./bash CPU_nice.sh

root@vagrant:/vagrant# bash CPU_nice.sh
Запуск процесса 1 с nice 10
Запуск процесса 2 с nice -10
Начало выполнения процесса 1 с PID 18187
Начало выполнения процесса 2 с PID 18189  

Описание
Функция cpu_intensive_task : продолжение бесконечного цикла с простой вычислительной задачей.  

Команда nice : Позволяет запускать процессы с разными приоритетами.  

Значения nice могут приниматься от -20 (наивысший приоритет) до 19 (наименьший приоритет).

Процесс 1 : запускается с приоритетом уровня nice 10.  

Процесс 2 : запускается с приоритетом уровня nice -10.

Тестирование:  

После запуска основного скрипта можно наблюдать за загрузкой ЦП с помощью команд top или htop.  
Процессы с разными значениями nice будут получать разное количество процессорного времени.  
Процесс с более высоким приоритетом ( nice -10) будет получать больше процессорного времени по сравнению с процессом с низким приоритетом ( nice 10).

```shell

root@vagrant:/vagrant# top
top - 10:33:44 up 57 min,  4 users,  load average: 4.25, 3.96, 2.61
Tasks: 158 total,   2 running, 156 sleeping,   0 stopped,   0 zombie
%Cpu(s):  6.5 us, 71.9 sy,  3.9 ni, 15.5 id,  0.0 wa,  0.0 hi,  2.2 si,  0.0 st
MiB Mem :   1963.8 total,   1543.4 free,    192.8 used,    227.6 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   1618.9 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  18189 root      10 -10    7476   3512   3244 D  42.9   0.2   0:38.19 bash
  13975 root      10 -10    7476   3608   3340 D  34.3   0.2   5:43.97 bash
  13974 root      30  10    7476   3556   3288 D  28.3   0.2   5:01.43 bash
  18187 root      30  10    7476   3572   3304 R  26.0   0.2   0:28.42 bash
   1247 vagrant   20   0   17468   8652   6016 S   2.5   0.4   0:06.98 sshd
  18578 root      20   0   10496   4008   3424 R   1.3   0.2   0:00.30 top
     17 root      20   0       0      0      0 I   0.6   0.0   0:19.48 kworker/0:1-events
     22 root      20   0       0      0      0 S   0.6   0.0   0:09.04 ksoftirqd/1
    453 root      rt   0  289452  27232   9072 S   0.6   1.4   0:03.88 multipathd
     14 root      20   0       0      0      0 I   0.3   0.0   0:09.38 rcu_sched
    898 root      20   0  293128   3004   2636 S   0.3   0.1   0:02.18 VBoxService
   5205 root      20   0       0      0      0 I   0.3   0.0   0:08.18 kworker/1:2-events
   8432 root      20   0       0      0      0 I   0.3   0.0   0:00.58 kworker/u4:0-events_power_efficient
  18555 vagrant   20   0    7372   3620   3360 S   0.3   0.2   0:00.12 bash
      1 root      20   0  166156  11552   8308 S   0.0   0.6   0:03.87 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.04 kthreadd
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 slub_flushwq
      6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 netns
      8 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/0:0H-events_highpri
     10 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_percpu_wq
     11 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_rude_
     12 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_trace
     13 root      20   0       0      0      0 S   0.0   0.0   0:00.50 ksoftirqd/0
     15 root      rt   0       0      0      0 S   0.0   0.0   0:00.21 migration/0
     16 root     -51   0       0      0      0 S   0.0   0.0   0:00.00 idle_inject/0
     18 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0
     19 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/1
```


Остановка процессов:  

Чтобы остановить процессы, запущенные скриптом, можно использовать команду kill:

Необходимо найти PID-процессы с помощью команды ps или pgrep:  

pgrep -f "cpu_intensive_task"  

root@vagrant:/vagrant# pgrep -f "cpu_intensive_task"
13974
13975  
18187
18189

Завершить процессы с помощью команды kill:  

kill -SIGTERM <pid1> <pid2>  

root@vagrant:/vagrant# kill 18187 18189

```shell

root@vagrant:/vagrant# top
top - 10:39:08 up  1:03,  4 users,  load average: 2.99, 3.80, 2.99
Tasks: 155 total,   3 running, 152 sleeping,   0 stopped,   0 zombie
%Cpu(s):  4.7 us, 36.1 sy,  1.4 ni, 57.6 id,  0.0 wa,  0.0 hi,  0.3 si,  0.0 st
MiB Mem :   1963.8 total,   1544.0 free,    192.2 used,    227.6 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   1619.6 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  13975 root      10 -10    7476   3608   3340 R  56.0   0.2   7:39.88 bash
  13974 root      30  10    7476   3556   3288 R  23.3   0.2   6:42.23 bash
  20237 root      20   0   10496   4004   3424 R   2.9   0.2   0:00.51 top
   1247 vagrant   20   0   17468   8660   6016 S   1.9   0.4   0:09.97 sshd
     17 root      20   0       0      0      0 I   1.0   0.0   0:22.14 kworker/0:1-events
     14 root      20   0       0      0      0 I   0.6   0.0   0:11.74 rcu_sched
    895 root      20   0  155484   1284   1144 S   0.3   0.1   0:04.04 VBoxDRMClient
  19944 vagrant   20   0    7372   3664   3404 S   0.3   0.2   0:00.41 bash
      1 root      20   0  166156  11552   8308 S   0.0   0.6   0:03.88 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.05 kthreadd
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 slub_flushwq
      6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 netns
      8 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/0:0H-events_highpri
     10 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_percpu_wq
     11 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_rude_
     12 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_trace
     13 root      20   0       0      0      0 S   0.0   0.0   0:00.60 ksoftirqd/0
     15 root      rt   0       0      0      0 S   0.0   0.0   0:00.23 migration/0
     16 root     -51   0       0      0      0 S   0.0   0.0   0:00.00 idle_inject/0
     18 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0
     19 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/1
     20 root     -51   0       0      0      0 S   0.0   0.0   0:00.00 idle_inject/1
     21 root      rt   0       0      0      0 S   0.0   0.0   0:00.76 migration/1
     22 root      20   0       0      0      0 S   0.0   0.0   0:13.09 ksoftirqd/1
     23 root      20   0       0      0      0 I   0.0   0.0   0:04.07 kworker/1:0-events
     24 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/1:0H-events_highpri
     25 root      20   0       0      0      0 S   0.0   0.0   0:00.03 kdevtmpfs
```


Где <pid1>и <pid2>— это идентификаторы запущенных процессов. 



В этом примере можно создать и управлять двумя конкурирующими процессами с приоритетами разных уровней в bash-скрипте.

-----------
end
 
