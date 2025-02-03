#!/bin/bash

# =============================================
# Функции управления .gitignore
# =============================================

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/logging.sh"

# Функция настройки .gitignore
setup_gitignore() {
    log_info "Настройка .gitignore..."
    log_info "Доступные шаблоны CMS:"
    log_info "1) WordPress"
    log_info "2) Drupal"
    log_info "3) Joomla"
    log_info "4) Bitrix"
    log_info "5) OpenCart"
    log_info "6) ModX"
    log_info "7) Пользовательский"
    log_info "8) Пропустить создание .gitignore"
    
    read -p "Выберите шаблон (1-8): " gitignore_choice
    
    if [ "$gitignore_choice" != "8" ]; then
        case $gitignore_choice in
            1) create_wordpress_gitignore ;;
            2) create_drupal_gitignore ;;
            3) create_joomla_gitignore ;;
            4) create_bitrix_gitignore ;;
            5) create_opencart_gitignore ;;
            6) create_modx_gitignore ;;
            7) create_custom_gitignore ;;
            *) 
                log_error "Неверный выбор. Создан пустой .gitignore."
                touch .gitignore
                ;;
        esac
        
        log_info "Файл .gitignore создан/обновлен"
        
        # Показываем содержимое файла
        log_info "Содержимое .gitignore:"
        cat .gitignore
        
        read -p "Хотите отредактировать .gitignore? (y/n): " edit_gitignore
        if [[ $edit_gitignore == "y" ]]; then
            if [ -n "$EDITOR" ]; then
                $EDITOR .gitignore
            else
                nano .gitignore
            fi
        fi
    fi
}

# Функция создания .gitignore для WordPress
create_wordpress_gitignore() {
    cat > .gitignore << 'EOL'
# WordPress игнорируемые файлы
wp-config.php
wp-content/uploads/
wp-content/cache/
wp-content/upgrade/
wp-content/backup-db/
wp-content/backups/
wp-content/blogs.dir/
wp-content/upgrade/
wp-content/backup-db/
wp-content/advanced-cache.php
wp-content/wp-cache-config.php
wp-content/cache/
wp-content/backups/
*.log
.htaccess
.htpasswd

# Медиафайлы
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.mov
*.mp4
*.mp3
*.flv
*.fla
*.swf
*.gz
*.zip
*.rar
*.7z
*.doc
*.docx
*.pdf
*.webp
*.svg
*.woff
*.woff2
*.eot
*.ttf
*.otf

# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOL
}

# Функция создания .gitignore для Drupal
create_drupal_gitignore() {
    cat > .gitignore << 'EOL'
# Drupal игнорируемые файлы
sites/*/settings*.php
sites/*/files
sites/*/private
files/*
/cache
.htaccess
.htpasswd
*.log
/sites/default/files
/sites/default/private
/sites/default/settings.php
/sites/default/settings.local.php

# Composer
/vendor/
composer.phar

# Drush
/drush/contrib/
/drush/sites/

# Медиафайлы
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.mov
*.mp4
*.mp3
*.flv
*.fla
*.swf
*.gz
*.zip
*.rar
*.7z
*.doc
*.docx
*.pdf
*.webp
*.svg
*.woff
*.woff2
*.eot
*.ttf
*.otf

# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOL
}

# Функция создания .gitignore для Joomla
create_joomla_gitignore() {
    cat > .gitignore << 'EOL'
# Joomla игнорируемые файлы
/administrator/cache/*
/cache/*
/logs/*
/tmp/*
/configuration.php
/images/
/media/
.htaccess
.htpasswd
*.log
/administrator/logs/

# Медиафайлы
/images/
/media/
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.mov
*.mp4
*.mp3
*.flv
*.fla
*.swf
*.gz
*.zip
*.rar
*.7z
*.doc
*.docx
*.pdf
*.webp
*.svg
*.woff
*.woff2
*.eot
*.ttf
*.otf

# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOL
}

# Функция создания .gitignore для Bitrix
create_bitrix_gitignore() {
    cat > .gitignore << 'EOL'
# Bitrix игнорируемые файлы
/bitrix/*
!/bitrix/templates/
!/bitrix/components/
!/bitrix/modules/
/upload
/upload/
.htaccess
.htpasswd
*.log

# Конфигурационные файлы
/bitrix/.settings.php
/bitrix/php_interface/dbconn.php
/bitrix/.settings_extra.php

# Временные файлы
/bitrix/backup/
/bitrix/cache/
/bitrix/managed_cache/
/bitrix/stack_cache/
/bitrix/tmp/

# Медиафайлы
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.mov
*.mp4
*.mp3
*.flv
*.fla
*.swf
*.gz
*.zip
*.rar
*.7z
*.doc
*.docx
*.pdf
*.webp
*.svg
*.woff
*.woff2
*.eot
*.ttf
*.otf

# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOL
}

# Функция создания .gitignore для OpenCart
create_opencart_gitignore() {
    cat > .gitignore << 'EOL'
# OpenCart игнорируемые файлы
/system/storage/
/image/
/image
/config.php
/admin/config.php
/system/storage/cache/*
/system/storage/logs/*
error_log
*.log

# Загрузки
/system/storage/download/*

# XML файлы
feed-*.xml
*_feed_yandex.xml
sitemap.xml
yml.xml

# Файлы верификации
google*.html
yandex_*.html
mailru-domain*.html
wmail_*.html

# Медиафайлы
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.svg
*.webp
*.mp3
*.mp4
*.wav
*.avi
*.mov
*.wmv
*.flv
*.mkv
*.webm
*.m4v
*.m4a
*.aac
*.ogg
*.wma

# Документы
*.pdf
*.csv
*.xls
*.xlsx
*.doc
*.docx

# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOL
}

# Функция создания .gitignore для ModX
create_modx_gitignore() {
    cat > .gitignore << 'EOL'
# ModX игнорируемые файлы
/core/cache/*
/core/export/*
/core/packages/*
/assets/cache/*
/assets/components/*
/assets/images/*
config.core.php
.htaccess
.htpasswd
*.log

# Конфигурационные файлы
/config.core.php
/connectors/config.core.php
/manager/config.core.php

# Кэш и временные файлы
/core/cache/
/core/packages/
/core/docs/
/core/export/
/assets/cache/
/assets/components/*/cache/
/assets/backups/

# Медиафайлы
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.mov
*.mp4
*.mp3
*.flv
*.fla
*.swf
*.gz
*.zip
*.rar
*.7z
*.doc
*.docx
*.pdf
*.webp
*.svg
*.woff
*.woff2
*.eot
*.ttf
*.otf

# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOL
}

# Функция создания пользовательского .gitignore
create_custom_gitignore() {
    log_info "Создание пользовательского .gitignore"
    log_info "Выберите категории файлов для игнорирования:"
    
    local ignore_content=""
    
    # Системные файлы
    read -p "Игнорировать системные файлы (DS_Store, Thumbs.db и т.д.)? (y/n): " ignore_system
    if [[ $ignore_system == "y" ]]; then
        ignore_content+="
# Системные файлы
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
"
    fi
    
    # Медиафайлы
    read -p "Игнорировать медиафайлы (изображения, видео, аудио)? (y/n): " ignore_media
    if [[ $ignore_media == "y" ]]; then
        ignore_content+="
# Медиафайлы
*.jpg
*.jpeg
*.png
*.gif
*.ico
*.mov
*.mp4
*.mp3
*.flv
*.fla
*.swf
*.webp
*.svg
"
    fi
    
    # Архивы
    read -p "Игнорировать архивы? (y/n): " ignore_archives
    if [[ $ignore_archives == "y" ]]; then
        ignore_content+="
# Архивы
*.gz
*.zip
*.rar
*.7z
*.tar
*.tar.gz
"
    fi
    
    # Логи
    read -p "Игнорировать лог-файлы? (y/n): " ignore_logs
    if [[ $ignore_logs == "y" ]]; then
        ignore_content+="
# Логи
*.log
error_log
debug.log
"
    fi
    
    # Конфигурационные файлы
    read -p "Игнорировать конфигурационные файлы? (y/n): " ignore_config
    if [[ $ignore_config == "y" ]]; then
        ignore_content+="
# Конфигурационные файлы
.htaccess
.htpasswd
*.conf
*.config
*.ini
"
    fi
    
    # Кэш и временные файлы
    read -p "Игнорировать кэш и временные файлы? (y/n): " ignore_cache
    if [[ $ignore_cache == "y" ]]; then
        ignore_content+="
# Кэш и временные файлы
/cache/
/tmp/
*.tmp
*.temp
"
    fi
    
    # Пользовательские паттерны
    read -p "Хотите добавить собственные паттерны? (y/n): " add_custom
    if [[ $add_custom == "y" ]]; then
        log_info "Введите паттерны по одному в строке (пустая строка для завершения):"
        while true; do
            read -p "> " pattern
            if [ -z "$pattern" ]; then
                break
            fi
            ignore_content+="
$pattern"
        done
    fi
    
    # Записываем содержимое в файл
    echo "$ignore_content" > .gitignore
    
    log_info "Пользовательский .gitignore создан"
} 