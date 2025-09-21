#!/bin/bash

# =============================================================================
# Скрипт скачивания и установки Oracle Database 11.2.0.4.0
# Автор: DevOps Expert Team
# Версия: 1.2
# Описание: Скачивает скрипт установки Oracle и запускает интерактивную установку
# 
# Использование:
# wget https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/download-and-install.sh
# chmod +x download-and-install.sh
# sudo ./download-and-install.sh
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

# URL скрипта установки
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-11g-install.sh"
INSTALL_SCRIPT_NAME="oracle-11g-install.sh"

# Функции логирования
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Проверка прав root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен запускаться с правами root"
        log_info "Используйте: sudo $0"
        exit 1
    fi
}

# Проверка доступности wget
check_wget() {
    if ! command -v wget >/dev/null 2>&1; then
        log_warning "wget не найден. Установка wget..."
        apt update -y
        apt install -y wget
    fi
}

# Скачивание скрипта установки
download_install_script() {
    log "Скачивание скрипта установки Oracle..."
    
    if [[ -f "$INSTALL_SCRIPT_NAME" ]]; then
        log_warning "Файл $INSTALL_SCRIPT_NAME уже существует"
        read -p "Перезаписать? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Используется существующий файл $INSTALL_SCRIPT_NAME"
            return
        fi
    fi
    
    log_info "Скачивание с: $INSTALL_SCRIPT_URL"
    if wget -O "$INSTALL_SCRIPT_NAME" "$INSTALL_SCRIPT_URL"; then
        log "Скрипт успешно скачан: $INSTALL_SCRIPT_NAME"
    else
        log_error "Ошибка при скачивании скрипта"
        exit 1
    fi
}

# Установка прав на скрипт
set_permissions() {
    log "Установка прав на скрипт..."
    chmod +x "$INSTALL_SCRIPT_NAME"
    log "Права установлены: $INSTALL_SCRIPT_NAME"
}

# Запуск установки
run_installation() {
    log "Запуск интерактивной установки Oracle..."
    log_info "Следуйте инструкциям на экране для ввода:"
    log_info "- Oracle SID (например: orcl, prod, dev)"
    log_info "- Название базы данных (например: PROD, DEV, TEST)"
    log_info "- Пароли для пользователей SYS, SYSTEM, SYSMAN, DBSNMP"
    echo
    
    # Запуск основного скрипта установки
    bash "$INSTALL_SCRIPT_NAME"
}

# Очистка временных файлов
cleanup() {
    log "Очистка временных файлов..."
    if [[ -f "$INSTALL_SCRIPT_NAME" ]]; then
        read -p "Удалить скачанный скрипт $INSTALL_SCRIPT_NAME? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$INSTALL_SCRIPT_NAME"
            log "Скрипт $INSTALL_SCRIPT_NAME удален"
        else
            log_info "Скрипт $INSTALL_SCRIPT_NAME сохранен для повторного использования"
        fi
    fi
}

# Основная функция
main() {
    log "=== Скачивание и установка Oracle Database 11.2.0.4.0 ==="
    echo
    
    # Проверки
    check_root
    check_wget
    
    # Скачивание и установка
    download_install_script
    set_permissions
    run_installation
    
    # Очистка
    cleanup
    
    log "=== Установка Oracle завершена! ==="
    log_info "Проверьте логи установки в /var/log/oracle-install.log"
}

# Запуск основной функции
main "$@"
