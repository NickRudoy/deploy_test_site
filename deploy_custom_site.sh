#!/bin/bash

# =============================================
# Основной скрипт развертывания сайта
# =============================================

# Загружаем все модули
SCRIPT_DIR="$(dirname "$0")/scripts"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/logging.sh"
source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/monitoring.sh"
source "$SCRIPT_DIR/git.sh"
source "$SCRIPT_DIR/gitignore.sh"

# Основная последовательность выполнения
{
    # Инициализация логирования
    mkdir -p "$DEFAULT_LOG_DIR"
    exec 1> >(tee -a "${DEFAULT_LOG_DIR}/deployment.log")
    exec 2> >(tee -a "${DEFAULT_LOG_DIR}/deployment.log" >&2)
    
    log_info "Начало развертывания..."
    
    # Проверка и настройка окружения
    setup_environment || exit 1
    check_system_requirements || exit 1
    check_security_updates
    
    # Мониторинг ресурсов перед началом
    monitor_resources
    check_disk_performance
    check_network_performance
    
    # Инициализация настроек
    initialize_settings
    
    # Настройка Git с валидацией
    if ! validate_domain "$GITLAB_DOMAIN"; then
        log_error "Неверный домен GitLab"
        exit 1
    fi
    
    if ! validate_port "$GITLAB_SSH_PORT"; then
        log_error "Неверный SSH порт"
        exit 1
    fi
    
    if ! validate_email "$DEFAULT_GIT_EMAIL"; then
        log_error "Неверный email Git"
        exit 1
    fi
    
    test_gitlab_connection || exit 1
    setup_git_config "$DEFAULT_GIT_USER" "$DEFAULT_GIT_EMAIL" || exit 1
    
    # Формируем URL репозитория
    REPO_URL="ssh://${GITLAB_DEFAULT_USER}@${GITLAB_DOMAIN}:${GITLAB_SSH_PORT}/path/to/repo.git"
    setup_git_repository "$REPO_URL" "$GITLAB_DEFAULT_BRANCH" || exit 1
    
    # Настройка веб-сервера и SSL с проверками безопасности
    if [ "$CAN_CONFIGURE_WEBSERVER" = true ]; then
        # Проверяем безопасность директорий
        check_directory_security "/etc/nginx" "Nginx" || check_directory_security "/etc/apache2" "Apache"
        check_directory_security "$DEFAULT_LOG_DIR" "логов"
        
        setup_webserver
        
        # Проверяем пароль для HTTP аутентификации
        if ! validate_password_strength "$DEFAULT_HTTP_PASSWORD"; then
            log_warn "Небезопасный пароль для HTTP аутентификации"
            read -p "Продолжить? (y/n): " continue_setup
            if [[ $continue_setup != "y" ]]; then
                exit 1
            fi
        fi
        
        setup_http_auth
        setup_ssl
        
        # Проверяем права доступа конфигурационных файлов
        check_file_permissions ".htaccess" "644" "файла .htaccess"
        check_file_permissions ".htpasswd" "644" "файла .htpasswd"
    fi
    
    # Создание бэкапа перед изменениями
    create_backup "."
    
    # Мониторинг процессов
    monitor_processes
    
    # Оптимизация производительности
    optimize_performance
    
    # Создание отчета и очистка
    create_deployment_report
    cleanup_temp_files
    rotate_logs
    check_services_status
    
    # Финальный мониторинг ресурсов
    monitor_resources
    
    # Очистка конфиденциальных данных
    secure_clean_variables "DEFAULT_HTTP_PASSWORD" "GITLAB_SSH_PORT"
    
    log_info "Развертывание завершено успешно!"
} || {
    # В случае ошибки
    log_error "Произошла ошибка при развертывании"
    exit 1
} 