#!/bin/bash

# =============================================================================
# Скрипт быстрой установки Oracle Database 11.2.0.4.0 с GitHub
# Автор: DevOps Expert Team
# Версия: 1.0
# Описание: Установка Oracle с GitHub репозитория
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

# Переменные
REPO_URL="https://github.com/ViktorTimofeev/devops-src.git"
TEMP_DIR="/tmp/oracle-install"
INSTALL_SCRIPT="oracle/oracle-11g-install.sh"

# Логирование
LOG_FILE="/var/log/oracle-github-install.log"
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

# Проверка прав root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен запускаться с правами root"
        exit 1
    fi
}

# Проверка системы
check_system() {
    log "Проверка системы..."
    
    # Проверка ОС
    if [[ ! -f /etc/debian_version ]] && [[ ! -f /etc/lsb-release ]]; then
        log_error "Этот скрипт предназначен для Debian/Ubuntu"
        exit 1
    fi
    
    # Проверка архитектуры
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]]; then
        log_error "Oracle 11g поддерживает только архитектуру x86_64"
        exit 1
    fi
    
    # Проверка памяти
    MEMORY_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEMORY_GB=$((MEMORY_KB / 1024 / 1024))
    
    if [[ $MEMORY_GB -lt 2 ]]; then
        log_error "Требуется минимум 2GB RAM, обнаружено: ${MEMORY_GB}GB"
        exit 1
    fi
    
    log "Система: $(lsb_release -d | cut -f2)"
    log "Архитектура: $ARCH"
    log "Память: ${MEMORY_GB}GB"
}

# Установка необходимых пакетов
install_dependencies() {
    log "Установка зависимостей..."
    
    apt update -y
    apt install -y git curl wget
    
    log "Зависимости установлены"
}

# Скачивание скриптов с GitHub
download_scripts() {
    log "Скачивание скриптов Oracle с GitHub..."
    
    # Очистка временной директории
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Клонирование репозитория
    git clone "$REPO_URL" "$TEMP_DIR"
    
    # Проверка наличия скрипта установки
    if [[ ! -f "$TEMP_DIR/$INSTALL_SCRIPT" ]]; then
        log_error "Скрипт установки не найден: $TEMP_DIR/$INSTALL_SCRIPT"
        exit 1
    fi
    
    log "Скрипты Oracle скачаны с GitHub"
}

# Запуск установки Oracle
run_installation() {
    log "Запуск установки Oracle Database 11.2.0.4.0..."
    
    # Переход в директорию с скриптами
    cd "$TEMP_DIR"
    
    # Установка прав на выполнение
    chmod +x "$INSTALL_SCRIPT"
    
    # Запуск скрипта установки
    ./"$INSTALL_SCRIPT"
    
    log "Установка Oracle завершена"
}

# Очистка временных файлов
cleanup() {
    log "Очистка временных файлов..."
    
    rm -rf "$TEMP_DIR"
    
    log "Временные файлы очищены"
}

# Создание отчета об установке
create_install_report() {
    log "Создание отчета об установке..."
    
    local REPORT_FILE="/root/oracle-install-report-$(date '+%Y-%m-%d').txt"
    
    cat > "$REPORT_FILE" << EOF
=============================================================================
ОТЧЕТ ОБ УСТАНОВКЕ ORACLE DATABASE 11.2.0.4.0
Дата установки: $(date)
Версия скрипта: 1.0
Источник: GitHub ($REPO_URL)
=============================================================================

СИСТЕМНАЯ ИНФОРМАЦИЯ:
- ОС: $(lsb_release -d | cut -f2)
- Ядро: $(uname -r)
- Архитектура: $(uname -m)
- Память: $(free -h | grep Mem | awk '{print $2}')

ПЕРЕМЕННЫЕ ORACLE:
- ORACLE_BASE: /opt/oracle
- ORACLE_HOME: /opt/oracle/product/11.2.0/dbhome_1
- ORACLE_SID: orcl
- ORACLE_USER: oracle

УСТАНОВЛЕННЫЕ КОМПОНЕНТЫ:
- Oracle Database 11.2.0.4.0
- Oracle Listener
- Oracle Enterprise Manager
- Необходимые системные пакеты

СЛЕДУЮЩИЕ ШАГИ:
1. Скачайте Oracle Database 11.2.0.4.0 с официального сайта Oracle
2. Распакуйте архив в /tmp/database/
3. Запустите установку от имени пользователя oracle:
   su - oracle
   cd /tmp/database
   ./runInstaller -silent -responseFile /tmp/oracle_install.rsp
4. После установки запустите root.sh:
   sudo /opt/oracle/product/11.2.0/dbhome_1/root.sh

ПРОВЕРКА УСТАНОВКИ:
- Запустите: make -C /tmp/oracle-install check
- Или: ./oracle-check.sh

ЛОГИ УСТАНОВКИ:
- Основной лог: $LOG_FILE
- Отчет: $REPORT_FILE

=============================================================================
EOF

    log "Отчет об установке создан: $REPORT_FILE"
}

# Основная функция
main() {
    log "Начинаем установку Oracle Database 11.2.0.4.0 с GitHub..."
    
    # Проверки
    check_root
    check_system
    
    # Установка
    install_dependencies
    download_scripts
    run_installation
    
    # Завершение
    create_install_report
    cleanup
    
    log "Установка Oracle Database 11.2.0.4.0 с GitHub завершена!"
    log "Следующие шаги:"
    log "1. Скачайте Oracle Database 11.2.0.4.0 с официального сайта"
    log "2. Распакуйте архив в /tmp/database/"
    log "3. Запустите установку от имени пользователя oracle"
    log "4. Проверьте установку командой: make -C /tmp/oracle-install check"
}

# Запуск основной функции
main "$@"
