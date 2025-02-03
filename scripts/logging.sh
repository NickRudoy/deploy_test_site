#!/bin/bash

# =============================================
# Функции логирования
# =============================================

source "$(dirname "$0")/config.sh"

# Функция логирования
log() {
    local level=$1
    local message=$2
    local color=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ $level -ge $CURRENT_LOG_LEVEL ]; then
        local level_str=""
        case $level in
            $LOG_LEVEL_DEBUG) level_str="DEBUG";;
            $LOG_LEVEL_INFO)  level_str="INFO ";;
            $LOG_LEVEL_WARN)  level_str="WARN ";;
            $LOG_LEVEL_ERROR) level_str="ERROR";;
        esac
        
        # Логируем в файл
        echo "[$timestamp] [$level_str] $message" >> "${DEFAULT_LOG_DIR}/deployment.log"
        
        # Выводим в консоль с цветом
        echo -e "${color}[$timestamp] [$level_str] $message${NC}"
    fi
}

# Функции для разных уровней логирования
log_debug() { log $LOG_LEVEL_DEBUG "$1" "$BLUE"; }
log_info()  { log $LOG_LEVEL_INFO  "$1" "$GREEN"; }
log_warn()  { log $LOG_LEVEL_WARN  "$1" "$YELLOW"; }
log_error() { log $LOG_LEVEL_ERROR "$1" "$RED"; } 