#!/bin/bash

# =============================================
# Функции работы с Git
# =============================================

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/logging.sh"
source "$(dirname "$0")/validation.sh"

# Функция проверки подключения к GitLab
test_gitlab_connection() {
    local max_attempts=3
    local attempt=1
    local connected=false
    
    log_info "Проверка SSH подключения к GitLab..."
    log_info "Попытка подключения к $GITLAB_DOMAIN через порт $GITLAB_SSH_PORT..."
    
    while [ $attempt -le $max_attempts ] && [ "$connected" = false ]; do
        log_info "Попытка подключения $attempt из $max_attempts"
        
        if ssh -p $GITLAB_SSH_PORT -T "$GITLAB_DEFAULT_USER@$GITLAB_DOMAIN" 2>&1 | grep -q "Welcome to GitLab"; then
            connected=true
            log_info "Подключение успешно установлено"
        else
            local error_code=$?
            case $error_code in
                255)
                    log_error "Ошибка подключения. Проверьте:"
                    log_error "1. Правильность SSH ключа"
                    log_error "2. Добавлен ли ключ в GitLab"
                    log_error "3. Права доступа на файлы в .ssh"
                    log_error "4. Доступность порта $GITLAB_SSH_PORT"
                    ;;
                *)
                    log_error "Ошибка подключения (код: $error_code)"
                    ;;
            esac
        fi
        
        attempt=$((attempt + 1))
        [ "$connected" = false ] && [ $attempt -le $max_attempts ] && sleep 2
    done
    
    if [ "$connected" = true ]; then
        update_ssh_config "$GITLAB_DOMAIN"
    fi
    
    return $([ "$connected" = true ] && echo 0 || echo 1)
}

# Функция обновления SSH конфигурации
update_ssh_config() {
    local domain="$1"
    
    log_info "Обновление SSH конфигурации для домена $domain..."
    
    cat > ~/.ssh/config << EOL
Host $domain
    HostName $domain
    Port $GITLAB_SSH_PORT
    User $GITLAB_DEFAULT_USER
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    PreferredAuthentications publickey
EOL
    
    chmod 600 ~/.ssh/config
    log_info "SSH конфигурация обновлена"
    log_info "Настроено подключение через порт $GITLAB_SSH_PORT"
}

# Функция настройки конфигурации Git
setup_git_config() {
    local git_user="$1"
    local git_email="$2"
    
    log_info "Настройка конфигурации Git..."
    
    # Основные настройки пользователя
    git config --global user.name "$git_user"
    git config --global user.email "$git_email"
    
    # Настройка обработки переносов строк
    log_info "Настройка обработки переносов строк..."
    git config --global core.autocrlf false
    git config --global core.filemode false
    git config --global core.eol lf
    git config --global core.safecrlf false
    
    # Настройка сравнения файлов
    log_info "Настройка сравнения файлов..."
    git config --global diff.algorithm histogram
    git config --global diff.renames copies
    git config --global diff.renameLimit 999999
    
    # Настройка формата логов
    log_info "Настройка формата логов..."
    git config --global format.pretty '%h %ad | %s%d [%an]'
    git config --global log.date short
    
    # Настройка цветов
    log_info "Настройка цветового оформления..."
    git config --global color.ui true
    git config --global color.status auto
    git config --global color.branch auto
    git config --global color.diff auto
    
    # Настройка алиасов
    log_info "Настройка алиасов Git..."
    read -p "Хотите настроить алиасы Git? (y/n): " setup_aliases
    if [[ $setup_aliases == "y" ]]; then
        setup_git_aliases
    fi
    
    # Настройка поведения pull
    setup_git_pull_behavior
    
    # Настройка редактора
    setup_git_editor
    
    # Проверка конфигурации
    log_info "Текущая конфигурация Git:"
    git config --list
    
    read -p "Конфигурация Git верна? (y/n): " config_correct
    if [[ $config_correct != "y" ]]; then
        log_error "Отмена настройки Git. Пожалуйста, запустите настройку заново."
        return 1
    fi
    
    log_info "Настройка Git успешно завершена"
    return 0
}

# Функция настройки алиасов Git
setup_git_aliases() {
    while true; do
        log_info "Доступные стандартные алиасы:"
        log_info "1. st -> status"
        log_info "2. ci -> commit"
        log_info "3. br -> branch"
        log_info "4. co -> checkout"
        log_info "5. df -> diff"
        log_info "6. lg -> красивый лог с графом"
        log_info "7. Добавить свой алиас"
        log_info "8. Завершить настройку алиасов"
        
        read -p "Выберите опцию (1-8): " alias_choice
        case $alias_choice in
            1)
                git config --global alias.st status
                log_info "Добавлен алиас: st -> status"
                ;;
            2)
                git config --global alias.ci commit
                log_info "Добавлен алиас: ci -> commit"
                ;;
            3)
                git config --global alias.br branch
                log_info "Добавлен алиас: br -> branch"
                ;;
            4)
                git config --global alias.co checkout
                log_info "Добавлен алиас: co -> checkout"
                ;;
            5)
                git config --global alias.df diff
                log_info "Добавлен алиас: df -> diff"
                ;;
            6)
                git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
                log_info "Добавлен алиас: lg -> красивый лог с графом"
                ;;
            7)
                read -p "Введите имя алиаса: " custom_alias
                read -p "Введите команду для алиаса: " custom_command
                git config --global alias.$custom_alias "$custom_command"
                log_info "Добавлен алиас: $custom_alias -> $custom_command"
                ;;
            8)
                break
                ;;
            *)
                log_error "Неверный выбор"
                ;;
        esac
    done
}

# Функция настройки поведения pull
setup_git_pull_behavior() {
    log_info "Настройка поведения pull..."
    log_info "1. merge (создает merge-коммит)"
    log_info "2. rebase (перебазирует локальные изменения)"
    log_info "3. ff-only (только fast-forward)"
    
    while true; do
        read -p "Выберите стратегию pull (1-3): " pull_strategy
        case $pull_strategy in
            1)
                git config --global pull.rebase false
                log_info "Установлена стратегия merge для pull"
                break
                ;;
            2)
                git config --global pull.rebase true
                log_info "Установлена стратегия rebase для pull"
                break
                ;;
            3)
                git config --global pull.ff only
                log_info "Установлена стратегия fast-forward only для pull"
                break
                ;;
            *)
                log_error "Неверный выбор"
                ;;
        esac
    done
}

# Функция настройки редактора Git
setup_git_editor() {
    log_info "Настройка редактора по умолчанию..."
    log_info "1. vim"
    log_info "2. nano"
    log_info "3. другой"
    
    while true; do
        read -p "Выберите редактор (1-3): " editor_choice
        case $editor_choice in
            1)
                git config --global core.editor "vim"
                log_info "Установлен редактор vim"
                break
                ;;
            2)
                git config --global core.editor "nano"
                log_info "Установлен редактор nano"
                break
                ;;
            3)
                read -p "Введите команду редактора: " custom_editor
                git config --global core.editor "$custom_editor"
                log_info "Установлен редактор $custom_editor"
                break
                ;;
            *)
                log_error "Неверный выбор"
                ;;
        esac
    done
}

# Функция настройки репозитория
setup_git_repository() {
    local repo_url="$1"
    local branch_name="$2"
    
    log_info "Настройка Git репозитория..."
    
    # Проверяем текущую директорию
    if [ ! -w "." ]; then
        log_error "Нет прав на запись в текущую директорию!"
        return 1
    fi
    
    # Проверяем существование .git директории
    if [ -d ".git" ]; then
        log_warn "Обнаружен существующий Git репозиторий"
        read -p "Хотите пересоздать репозиторий? (y/n): " recreate_repo
        if [[ $recreate_repo == "y" ]]; then
            log_info "Создание бэкапа существующего репозитория..."
            create_backup ".git"
            rm -rf .git
            log_info "Существующий репозиторий удален"
        else
            log_info "Продолжаем с существующим репозиторием"
        fi
    fi
    
    # Инициализация нового репозитория если нужно
    if [ ! -d ".git" ]; then
        log_info "Инициализация нового Git репозитория..."
        if ! git init; then
            log_error "Ошибка при инициализации репозитория"
            return 1
        fi
    fi
    
    # Добавляем текущую директорию в safe.directory
    log_info "Настройка безопасной директории..."
    git config --global --add safe.directory "$PWD"
    
    # Удаляем существующий remote origin если есть
    if git remote | grep -q "^origin$"; then
        log_info "Удаление существующего remote origin..."
        git remote remove origin
    fi
    
    # Добавляем новый remote
    log_info "Добавление remote origin..."
    if ! git remote add origin "$repo_url"; then
        log_error "Ошибка при добавлении удаленного репозитория"
        return 1
    fi
    
    # Настройка .gitignore
    setup_gitignore
    
    # Проверяем, есть ли файлы для коммита
    if [ -n "$(git status --porcelain)" ]; then
        log_info "Обнаружены изменения в файлах"
        git status
        
        read -p "Хотите добавить все файлы в репозиторий? (y/n): " add_files
        if [[ $add_files == "y" ]]; then
            log_info "Добавление файлов..."
            git add .
            
            read -p "Введите сообщение для начального коммита: " commit_message
            commit_message=${commit_message:-"Начальный коммит"}
            
            if ! git commit -m "$commit_message"; then
                log_error "Ошибка при создании коммита"
                return 1
            fi
        fi
    fi
    
    # Настройка ветки
    setup_git_branch "$branch_name"
    
    # Проверка настройки репозитория
    log_info "Проверка настройки репозитория:"
    log_info "Remote URL: $(git remote get-url origin)"
    log_info "Текущая ветка: $(git rev-parse --abbrev-ref HEAD)"
    log_info "Статус: "
    git status
    
    read -p "Настройка репозитория верна? (y/n): " repo_correct
    if [[ $repo_correct != "y" ]]; then
        log_error "Отмена настройки репозитория. Пожалуйста, проверьте настройки и попробуйте снова."
        return 1
    fi
    
    log_info "Настройка Git репозитория успешно завершена"
    return 0
}

# Функция настройки ветки Git
setup_git_branch() {
    local branch_name="$1"
    
    log_info "Настройка ветки..."
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    if [ "$current_branch" = "master" ] && [ "$branch_name" != "master" ]; then
        log_info "Переименование ветки master в $branch_name..."
        if ! git branch -m master "$branch_name"; then
            log_error "Ошибка при переименовании ветки"
            return 1
        fi
    elif [ "$current_branch" != "$branch_name" ]; then
        log_info "Создание и переключение на ветку $branch_name..."
        if ! git checkout -B "$branch_name"; then
            log_error "Ошибка при создании ветки"
            return 1
        fi
    fi
    
    # Настройка отслеживания удаленной ветки
    log_info "Настройка отслеживания удаленной ветки..."
    read -p "Отправить ветку $branch_name в удаленный репозиторий? (y/n): " push_branch
    if [[ $push_branch == "y" ]]; then
        read -p "Использовать force push? (y/n): " force_push
        if [[ $force_push == "y" ]]; then
            if ! git push -u origin "$branch_name" --force; then
                log_error "Ошибка при отправке ветки с force"
                return 1
            fi
        else
            if ! git push -u origin "$branch_name"; then
                log_error "Ошибка при отправке ветки"
                return 1
            fi
        fi
    fi
} 