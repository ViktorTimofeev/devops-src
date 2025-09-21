#!/bin/bash

# =============================================================================
# Скрипт исправления конфликтов пакетов
# Автор: DevOps Expert Team
# Версия: 1.0
# Описание: Исправление конфликтов пакетов в Debian 12
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
        exit 1
    fi
}

# Исправление конфликтов пакетов
fix_conflicts() {
    log "Начинаем исправление конфликтов пакетов..."
    
    # Обновление списка пакетов
    log "Обновление списка пакетов..."
    apt update -y
    
    # Удаление проблемных пакетов
    log "Проверка проблемных пакетов..."
    
    # Удаление старого ntp, если установлен
    if dpkg -l | grep -q "^ii.*ntp "; then
        log "Удаление старого пакета ntp..."
        apt remove -y ntp || log_warning "Не удалось удалить ntp"
    fi
    
    # Удаление iptables-persistent, если конфликтует с ufw
    if dpkg -l | grep -q "^ii.*iptables-persistent" && dpkg -l | grep -q "^ii.*ufw"; then
        log "Удаление iptables-persistent (конфликт с ufw)..."
        apt remove -y iptables-persistent || log_warning "Не удалось удалить iptables-persistent"
    fi
    
    # Исправление сломанных пакетов
    log "Исправление сломанных пакетов..."
    apt --fix-broken install -y || log_warning "Некоторые пакеты не удалось исправить"
    
    # Очистка зависимостей
    log "Очистка зависимостей..."
    apt autoremove -y
    apt autoclean
    
    # Установка недостающих пакетов
    log "Установка недостающих пакетов..."
    
    # Установка systemd-timesyncd (современная альтернатива ntp)
    if ! dpkg -l | grep -q "^ii.*systemd-timesyncd"; then
        log "Установка systemd-timesyncd..."
        apt install -y systemd-timesyncd
    fi
    
    # Установка ufw, если не установлен
    if ! dpkg -l | grep -q "^ii.*ufw"; then
        log "Установка ufw..."
        apt install -y ufw
    fi
    
    # Установка fail2ban, если не установлен
    if ! dpkg -l | grep -q "^ii.*fail2ban"; then
        log "Установка fail2ban..."
        apt install -y fail2ban
    fi
    
    log "Конфликты пакетов исправлены"
}

# Настройка systemd-timesyncd
configure_timesyncd() {
    log "Настройка systemd-timesyncd..."
    
    # Создание конфигурации
    cat > /etc/systemd/timesyncd.conf << 'EOF'
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
FallbackNTP=time.google.com time.cloudflare.com
PollIntervalMinSec=32
PollIntervalMaxSec=2048
RootDistanceMaxSec=5
EOF

    # Включение службы
    systemctl enable systemd-timesyncd
    systemctl start systemd-timesyncd
    
    # Синхронизация времени
    timedatectl set-ntp true
    
    # Проверка статуса
    timedatectl status
    
    log "systemd-timesyncd настроен"
}

# Проверка статуса пакетов
check_package_status() {
    log "Проверка статуса пакетов..."
    
    local packages=("ufw" "fail2ban" "systemd-timesyncd" "openssh-server" "auditd" "apparmor")
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii.*$package"; then
            log "$package: Установлен ✓"
        else
            log_warning "$package: НЕ УСТАНОВЛЕН"
        fi
    done
}

# Основная функция
main() {
    log "Начинаем исправление конфликтов пакетов..."
    
    # Проверки
    check_root
    
    # Исправление
    fix_conflicts
    configure_timesyncd
    check_package_status
    
    log "Исправление конфликтов завершено!"
    log "Рекомендуется перезагрузить сервер: reboot"
}

# Запуск основной функции
main "$@"
