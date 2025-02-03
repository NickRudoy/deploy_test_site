#!/bin/bash

# =============================================
# Функции валидации и безопасности
# =============================================

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/logging.sh"

# Функция валидации домена
validate_domain() {
    local domain="$1"
    local domain_regex="^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"
    
    if [[ ! "$domain" =~ $domain_regex ]]; then
        log_error "Неверный формат домена: $domain"
        return 1
    fi
    return 0
}

# Функция валидации порта
validate_port() {
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        log_error "Неверный порт: $port (должен быть от 1 до 65535)"
        return 1
    fi
    return 0
}

# Функция валидации email
validate_email() {
    local email="$1"
    local email_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    
    if [[ ! "$email" =~ $email_regex ]]; then
        log_error "Неверный формат email: $email"
        return 1
    fi
    return 0
}

# Функция проверки безопасности пароля
validate_password_strength() {
    local password="$1"
    local min_length=8
    
    if [ ${#password} -lt $min_length ]; then
        log_error "Пароль слишком короткий (минимум $min_length символов)"
        return 1
    fi
    
    if [[ ! "$password" =~ [A-Z] ]]; then
        log_error "Пароль должен содержать хотя бы одну заглавную букву"
        return 1
    fi
    
    if [[ ! "$password" =~ [a-z] ]]; then
        log_error "Пароль должен содержать хотя бы одну строчную букву"
        return 1
    fi
    
    if [[ ! "$password" =~ [0-9] ]]; then
        log_error "Пароль должен содержать хотя бы одну цифру"
        return 1
    fi
    
    if [[ ! "$password" =~ ['!@#$%^&*()_+'] ]]; then
        log_error "Пароль должен содержать хотя бы один специальный символ"
        return 1
    fi
    
    return 0
}

# Функция проверки прав доступа к файлу
check_file_permissions() {
    local file="$1"
    local required_perms="$2"
    local description="$3"
    
    if [ ! -e "$file" ]; then
        log_error "Файл не существует: $file"
        return 1
    fi
    
    local current_perms=$(stat -c "%a" "$file")
    if [ "$current_perms" != "$required_perms" ]; then
        log_warn "Неверные права доступа для $description: $file"
        log_warn "Текущие права: $current_perms, требуемые: $required_perms"
        
        read -p "Исправить права доступа? (y/n): " fix_perms
        if [[ $fix_perms == "y" ]]; then
            if ! chmod "$required_perms" "$file"; then
                log_error "Не удалось изменить права доступа"
                return 1
            fi
            log_info "Права доступа исправлены"
        else
            return 1
        fi
    fi
    
    return 0
}

# Функция проверки безопасности директории
check_directory_security() {
    local dir="$1"
    local description="$2"
    
    if [ ! -d "$dir" ]; then
        log_error "Директория не существует: $dir"
        return 1
    fi
    
    local owner=$(stat -c "%U" "$dir")
    if [ "$owner" != "$USER" ]; then
        log_warn "Директория $description принадлежит другому пользователю: $owner"
        return 1
    fi
    
    local perms=$(stat -c "%a" "$dir")
    if [ "$perms" != "755" ] && [ "$perms" != "750" ]; then
        log_warn "Небезопасные права доступа для директории $description: $perms"
        read -p "Установить безопасные права доступа (755)? (y/n): " fix_perms
        if [[ $fix_perms == "y" ]]; then
            chmod 755 "$dir"
            log_info "Права доступа исправлены"
        fi
    fi
    
    return 0
}

# Функция безопасной очистки переменных
secure_clean_variables() {
    local vars=("$@")
    for var in "${vars[@]}"; do
        if [ -n "${!var}" ]; then
            eval "$var=''"
            unset "$var"
        fi
    done
}

# Функция проверки наличия обновлений безопасности
check_security_updates() {
    log_info "Проверка обновлений безопасности..."
    
    if command -v apt-get >/dev/null 2>&1; then
        apt-get -s upgrade | grep -i security
    elif command -v yum >/dev/null 2>&1; then
        yum check-update --security
    else
        log_warn "Не удалось проверить обновления безопасности"
        return 1
    fi
    
    return 0
} 