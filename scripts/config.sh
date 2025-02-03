#!/bin/bash

# =============================================
# Конфигурационные параметры
# =============================================

# Объявляем переменные без значений по умолчанию
GITLAB_DOMAIN=""
GITLAB_SSH_PORT=""
GITLAB_DEFAULT_USER=""
GITLAB_DEFAULT_BRANCH=""
DEFAULT_GIT_USER=""
DEFAULT_GIT_EMAIL=""
DEFAULT_HTTP_USER=""
DEFAULT_HTTP_PASSWORD=""
HTTP_AUTH_REALM=""
DEFAULT_WEB_USER=""
DEFAULT_WEB_GROUP=""
DEFAULT_BACKUP_DIR=""
DEFAULT_LOG_DIR=""
DEFAULT_EXCLUDE_DIRS=""

# Объявляем переменные окружения
IS_SERVER=false
HAS_ROOT=false
CAN_CONFIGURE_WEBSERVER=false
CAN_CONFIGURE_SSL=false
ENVIRONMENT_TYPE=""

# Настройки безопасности
MIN_FREE_SPACE=500              # Минимальное свободное место в МБ

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'                    # Без цвета

# Уровни логирования
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO 