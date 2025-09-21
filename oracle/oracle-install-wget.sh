#!/bin/bash

# =============================================================================
# Простая установка Oracle Database 11.2.0.4.0 через wget
# Автор: DevOps Expert Team
# Версия: 1.1
# Описание: Простая установка Oracle через wget с значениями по умолчанию
# 
# Использование:
# wget -qO- https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-wget.sh | bash
# =============================================================================

# Настройка кодировки UTF-8
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Логирование
LOG_FILE="/var/log/oracle-install.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Функции логирования
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Проверка доступности wget
check_wget() {
    if ! command -v wget >/dev/null 2>&1; then
        log_error "wget не найден. Установка wget..."
        apt update -y
        apt install -y wget
    fi
}

# Основная функция
main() {
    log "Начинаем установку Oracle Database 11.2.0.4.0 через wget..."
    
    # Проверка wget
    check_wget
    
    # Скачивание и запуск основного скрипта
    log "Скачивание основного скрипта установки Oracle..."
    wget -qO- https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-11g-install.sh | bash
    
    log "Установка Oracle завершена!"
}

# Запуск основной функции
main "$@"
