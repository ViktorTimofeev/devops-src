#!/bin/bash

# =============================================================================
# Скрипт проверки безопасности сервера Debian 12
# Автор: DevOps Expert Team
# Версия: 1.1
# Описание: Комплексная проверка безопасности настроенного сервера
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
LOG_FILE="/var/log/security-check.log"
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

# Проверка SSH конфигурации
check_ssh_security() {
    log "Проверка безопасности SSH..."
    
    local issues=0
    
    # Проверка отключения root
    if grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
        log_error "SSH: Root доступ разрешен!"
        ((issues++))
    else
        log "SSH: Root доступ отключен ✓"
    fi
    
    # Проверка порта SSH
    if grep -q "^Port 22" /etc/ssh/sshd_config; then
        log_warning "SSH: Используется стандартный порт 22"
    else
        log "SSH: Используется нестандартный порт ✓"
    fi
    
    # Проверка аутентификации по паролю
    if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config; then
        log "SSH: Аутентификация по паролю отключена ✓"
    else
        log_warning "SSH: Аутентификация по паролю включена"
    fi
    
    # Проверка X11 forwarding
    if grep -q "X11Forwarding yes" /etc/ssh/sshd_config; then
        log_error "SSH: X11 forwarding включен!"
        ((issues++))
    else
        log "SSH: X11 forwarding отключен ✓"
    fi
    
    if [ $issues -eq 0 ]; then
        log "SSH безопасность: ОТЛИЧНО"
    else
        log_error "SSH безопасность: НАЙДЕНЫ ПРОБЛЕМЫ ($issues)"
    fi
}

# Проверка файрвола
check_firewall() {
    log "Проверка файрвола..."
    
    if command -v ufw >/dev/null 2>&1; then
        if ufw status | grep -q "Status: active"; then
            log "UFW: Активен ✓"
            
            # Проверка правил
            local rules=$(ufw status numbered | grep -c "^\[")
            log_info "UFW: Настроено $rules правил"
            
            # Проверка SSH правила
            if ufw status | grep -q "22/tcp"; then
                log "UFW: SSH правило настроено ✓"
            else
                log_warning "UFW: SSH правило не найдено"
            fi
        else
            log_error "UFW: НЕ АКТИВЕН!"
        fi
    else
        log_error "UFW не установлен!"
    fi
}

# Проверка fail2ban
check_fail2ban() {
    log "Проверка fail2ban..."
    
    if command -v fail2ban-client >/dev/null 2>&1; then
        if systemctl is-active --quiet fail2ban; then
            log "fail2ban: Активен ✓"
            
            # Проверка статуса jail
            if fail2ban-client status | grep -q "sshd"; then
                log "fail2ban: SSH jail активен ✓"
            else
                log_warning "fail2ban: SSH jail не активен"
            fi
        else
            log_error "fail2ban: НЕ АКТИВЕН!"
        fi
    else
        log_error "fail2ban не установлен!"
    fi
}

# Проверка автоматических обновлений
check_auto_updates() {
    log "Проверка автоматических обновлений..."
    
    if systemctl is-enabled --quiet unattended-upgrades; then
        log "Автообновления: Включены ✓"
    else
        log_warning "Автообновления: НЕ ВКЛЮЧЕНЫ"
    fi
    
    # Проверка конфигурации
    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
        log "Конфигурация автообновлений: Найдена ✓"
    else
        log_warning "Конфигурация автообновлений: НЕ НАЙДЕНА"
    fi
}

# Проверка пользователей
check_users() {
    log "Проверка пользователей..."
    
    # Поиск пользователей с правами sudo
    local sudo_users=$(getent group sudo | cut -d: -f4 | tr ',' ' ')
    local admin_found=false
    
    if [[ -n "$sudo_users" ]]; then
        log "Пользователи с правами sudo: $sudo_users ✓"
        
        # Проверка каждого пользователя sudo
        for user in $sudo_users; do
            if [[ "$user" != "root" ]]; then
                log "Пользователь $user: В группе sudo ✓"
                admin_found=true
                
                # Проверка SSH директории
                if [[ -d "/home/$user/.ssh" ]]; then
                    log "SSH директория для $user: Найдена ✓"
                else
                    log_warning "SSH директория для $user: НЕ НАЙДЕНА"
                fi
            fi
        done
        
        if [[ "$admin_found" == false ]]; then
            log_warning "Не найдено пользователей-администраторов (кроме root)"
        fi
    else
        log_error "НЕ НАЙДЕНО пользователей с правами sudo!"
    fi
    
    # Проверка заблокированных пользователей
    local locked_users=$(passwd -S | grep "L " | wc -l)
    log_info "Заблокированных пользователей: $locked_users"
}

# Проверка служб безопасности
check_security_services() {
    log "Проверка служб безопасности..."
    
    local services=("ssh" "ufw" "fail2ban" "auditd" "apparmor")
    local active_count=0
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "$service: Активен ✓"
            ((active_count++))
        else
            log_error "$service: НЕ АКТИВЕН!"
        fi
    done
    
    log_info "Активных служб безопасности: $active_count/${#services[@]}"
}

# Проверка сетевых настроек
check_network_security() {
    log "Проверка сетевых настроек..."
    
    # Проверка IP forwarding
    if [ "$(cat /proc/sys/net/ipv4/ip_forward)" -eq 0 ]; then
        log "IP forwarding: Отключен ✓"
    else
        log_warning "IP forwarding: Включен"
    fi
    
    # Проверка ICMP redirects
    if [ "$(cat /proc/sys/net/ipv4/conf/all/accept_redirects)" -eq 0 ]; then
        log "ICMP redirects: Отключены ✓"
    else
        log_warning "ICMP redirects: Включены"
    fi
    
    # Проверка SYN cookies
    if [ "$(cat /proc/sys/net/ipv4/tcp_syncookies)" -eq 1 ]; then
        log "SYN cookies: Включены ✓"
    else
        log_warning "SYN cookies: Отключены"
    fi
}

# Проверка открытых портов
check_open_ports() {
    log "Проверка открытых портов..."
    
    local open_ports=$(ss -tlnp | grep -v "127.0.0.1" | wc -l)
    log_info "Открытых портов: $open_ports"
    
    # Проверка критических портов
    local critical_ports=("22" "80" "443")
    
    for port in "${critical_ports[@]}"; do
        if ss -tlnp | grep -q ":$port "; then
            log "Порт $port: Открыт ✓"
        else
            log_warning "Порт $port: Закрыт"
        fi
    done
}

# Проверка логов безопасности
check_security_logs() {
    log "Проверка логов безопасности..."
    
    local log_files=("/var/log/auth.log" "/var/log/fail2ban.log" "/var/log/audit/audit.log")
    
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            local size=$(du -h "$log_file" | cut -f1)
            log "$log_file: Существует (размер: $size) ✓"
        else
            log_warning "$log_file: НЕ НАЙДЕН"
        fi
    done
    
    # Проверка недавних попыток входа
    local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 | wc -l)
    log_info "Недавних неудачных попыток входа: $failed_logins"
}

# Проверка антивируса
check_antivirus() {
    log "Проверка антивируса..."
    
    if command -v clamscan >/dev/null 2>&1; then
        log "ClamAV: Установлен ✓"
        
        # Проверка обновления баз
        if command -v freshclam >/dev/null 2>&1; then
            log "ClamAV: freshclam доступен ✓"
        else
            log_warning "ClamAV: freshclam недоступен"
        fi
    else
        log_error "ClamAV: НЕ УСТАНОВЛЕН!"
    fi
}

# Проверка rootkit сканеров
check_rootkit_scanners() {
    log "Проверка rootkit сканеров..."
    
    local scanners=("rkhunter" "chkrootkit")
    
    for scanner in "${scanners[@]}"; do
        if command -v "$scanner" >/dev/null 2>&1; then
            log "$scanner: Установлен ✓"
        else
            log_warning "$scanner: НЕ УСТАНОВЛЕН"
        fi
    done
}

# Проверка резервного копирования
check_backup() {
    log "Проверка резервного копирования..."
    
    if [ -f /usr/local/bin/backup-system.sh ]; then
        log "Скрипт резервного копирования: Найден ✓"
        
        if [ -d /backup ]; then
            local backup_count=$(find /backup -name "system-backup-*.tar.gz" 2>/dev/null | wc -l)
            log_info "Резервных копий: $backup_count"
        else
            log_warning "Директория резервных копий: НЕ НАЙДЕНА"
        fi
    else
        log_warning "Скрипт резервного копирования: НЕ НАЙДЕН"
    fi
}

# Проверка мониторинга
check_monitoring() {
    log "Проверка мониторинга..."
    
    if [ -f /usr/local/bin/system-monitor.sh ]; then
        log "Скрипт мониторинга: Найден ✓"
        
        # Проверка cron задач
        if crontab -l 2>/dev/null | grep -q "system-monitor.sh"; then
            log "Мониторинг в cron: Настроен ✓"
        else
            log_warning "Мониторинг в cron: НЕ НАСТРОЕН"
        fi
    else
        log_warning "Скрипт мониторинга: НЕ НАЙДЕН"
    fi
}

# Создание отчета о безопасности
create_security_report() {
    log "Создание отчета о безопасности..."
    
    local REPORT_FILE="/root/security-report-$(date '+%Y-%m-%d').txt"
    
    cat > "$REPORT_FILE" << EOF
=============================================================================
ОТЧЕТ О БЕЗОПАСНОСТИ СЕРВЕРА DEBIAN 12
Дата проверки: $(date)
Версия скрипта: 1.0
=============================================================================

СИСТЕМНАЯ ИНФОРМАЦИЯ:
- Версия ОС: $(cat /etc/debian_version)
- Ядро: $(uname -r)
- Архитектура: $(uname -m)
- Время работы: $(uptime -p)
- IP адрес: $(hostname -I)

СТАТУС СЛУЖБ БЕЗОПАСНОСТИ:
$(systemctl list-unit-files --state=enabled | grep -E "(ssh|ufw|fail2ban|auditd|apparmor)")

ОТКРЫТЫЕ ПОРТЫ:
$(ss -tlnp | grep -v "127.0.0.1")

ПРАВИЛА ФАЙРВОЛА:
$(ufw status verbose)

СТАТУС FAIL2BAN:
$(fail2ban-client status 2>/dev/null || echo "fail2ban не активен")

ПОЛЬЗОВАТЕЛИ С ПРАВАМИ SUDO:
$(getent group sudo | cut -d: -f4)

ПОЛЬЗОВАТЕЛИ-АДМИНИСТРАТОРЫ:
$(getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -v '^root$' | sed 's/^/- /')

ПОСЛЕДНИЕ НЕУДАЧНЫЕ ПОПЫТКИ ВХОДА:
$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "Логи не найдены")

РЕКОМЕНДАЦИИ ПО БЕЗОПАСНОСТИ:
1. Регулярно обновляйте систему
2. Мониторьте логи безопасности
3. Используйте SSH ключи вместо паролей
4. Регулярно проверяйте на rootkit
5. Настройте мониторинг ресурсов
6. Проверяйте целостность файлов

=============================================================================
EOF

    log "Отчет о безопасности создан: $REPORT_FILE"
}

# Основная функция
main() {
    log "Начинаем проверку безопасности сервера Debian 12..."
    
    # Проверки
    check_root
    
    # Проверки безопасности
    check_ssh_security
    check_firewall
    check_fail2ban
    check_auto_updates
    check_users
    check_security_services
    check_network_security
    check_open_ports
    check_security_logs
    check_antivirus
    check_rootkit_scanners
    check_backup
    check_monitoring
    
    # Создание отчета
    create_security_report
    
    log "Проверка безопасности завершена!"
    log "Подробный отчет сохранен в /root/security-report-$(date '+%Y-%m-%d').txt"
}

# Запуск основной функции
main "$@"
