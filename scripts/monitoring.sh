#!/bin/bash

# =============================================
# Функции мониторинга и производительности
# =============================================

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/logging.sh"

# Функция мониторинга использования ресурсов
monitor_resources() {
    log_info "Мониторинг использования ресурсов..."
    
    # CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    log_info "Использование CPU: $cpu_usage%"
    
    # Память
    local mem_total=$(free -m | awk '/Mem:/ {print $2}')
    local mem_used=$(free -m | awk '/Mem:/ {print $3}')
    local mem_usage=$((mem_used * 100 / mem_total))
    log_info "Использование памяти: $mem_usage% ($mem_used MB из $mem_total MB)"
    
    # Диск
    local disk_usage=$(df -h . | awk 'NR==2 {print $5}')
    log_info "Использование диска: $disk_usage"
    
    # Загрузка системы
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    log_info "Средняя загрузка: $load_avg"
    
    # Проверка критических значений
    if [ ${cpu_usage%.*} -gt 80 ]; then
        log_warn "Высокая загрузка CPU!"
    fi
    
    if [ $mem_usage -gt 80 ]; then
        log_warn "Высокое использование памяти!"
    fi
    
    if [ ${disk_usage%\%} -gt 80 ]; then
        log_warn "Высокое использование диска!"
    fi
}

# Функция проверки производительности сети
check_network_performance() {
    log_info "Проверка производительности сети..."
    
    local host="$GITLAB_DOMAIN"
    if ! ping -c 1 "$host" >/dev/null 2>&1; then
        log_error "Хост $host недоступен"
        return 1
    fi
    
    local ping_result=$(ping -c 5 "$host" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    log_info "Средняя задержка до $host: $ping_result ms"
    
    local dns_time=$(dig "$host" | grep "Query time:" | awk '{print $4}')
    log_info "Время DNS запроса: $dns_time ms"
    
    if command -v nc >/dev/null 2>&1; then
        log_info "Проверка открытых портов..."
        nc -zv "$host" "$GITLAB_SSH_PORT" 2>&1
    fi
    
    return 0
}

# Функция мониторинга процессов
monitor_processes() {
    log_info "Мониторинг процессов..."
    
    if [ "$CAN_CONFIGURE_WEBSERVER" = true ]; then
        case $WEB_SERVER in
            "apache")
                local apache_procs=$(pgrep -c apache2)
                log_info "Процессов Apache: $apache_procs"
                ;;
            "nginx")
                local nginx_procs=$(pgrep -c nginx)
                log_info "Процессов Nginx: $nginx_procs"
                ;;
        esac
        
        if pgrep php-fpm >/dev/null; then
            local php_procs=$(pgrep -c php-fpm)
            log_info "Процессов PHP-FPM: $php_procs"
        fi
    fi
    
    log_info "Топ 5 процессов по использованию CPU:"
    ps aux --sort=-%cpu | head -6
    
    log_info "Топ 5 процессов по использованию памяти:"
    ps aux --sort=-%mem | head -6
}

# Функция проверки производительности диска
check_disk_performance() {
    log_info "Проверка производительности диска..."
    
    local test_file="/tmp/disk_test_$$"
    
    log_info "Тест скорости записи..."
    local write_speed=$(dd if=/dev/zero of="$test_file" bs=1M count=100 2>&1 | grep copied | awk '{print $8 " " $9}')
    log_info "Скорость записи: $write_speed"
    
    log_info "Тест скорости чтения..."
    local read_speed=$(dd if="$test_file" of=/dev/null bs=1M count=100 2>&1 | grep copied | awk '{print $8 " " $9}')
    log_info "Скорость чтения: $read_speed"
    
    rm -f "$test_file"
    
    if command -v e4defrag >/dev/null 2>&1; then
        log_info "Проверка фрагментации..."
        e4defrag -c .
    fi
}

# Функция оптимизации производительности
optimize_performance() {
    log_info "Оптимизация производительности..."
    
    if [ "$HAS_ROOT" = true ]; then
        log_info "Очистка кэша системы..."
        sync
        echo 3 > /proc/sys/vm/drop_caches
    fi
    
    log_info "Очистка временных файлов..."
    find /tmp -type f -atime +7 -delete 2>/dev/null
    
    if command -v mysqlcheck >/dev/null 2>&1; then
        log_info "Оптимизация баз данных..."
        mysqlcheck --all-databases --optimize
    fi
    
    if [ "$HAS_ROOT" = true ]; then
        log_info "Очистка системных журналов..."
        journalctl --vacuum-time=7d
    fi
} 