#!/bin/bash

# =============================================================================
# Скрипт проверки установки Oracle Database 11.2.0.4.0
# Автор: DevOps Expert Team
# Версия: 1.0
# Описание: Проверка корректности установки Oracle
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

# Переменные Oracle
ORACLE_BASE="/opt/oracle"
ORACLE_HOME="/opt/oracle/product/11.2.0/dbhome_1"
ORACLE_SID=""
ORACLE_USER="oracle"

# Логирование
LOG_FILE="/var/log/oracle-check.log"
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

# Определение SID Oracle
detect_oracle_sid() {
    log "Определение Oracle SID..."
    
    # Попытка определить SID из переменных окружения пользователя oracle
    if [[ -f "/home/$ORACLE_USER/.bashrc" ]]; then
        local detected_sid=$(grep "export ORACLE_SID=" "/home/$ORACLE_USER/.bashrc" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
        if [[ -n "$detected_sid" ]]; then
            ORACLE_SID="$detected_sid"
            log "Oracle SID определен из .bashrc: $ORACLE_SID"
            return
        fi
    fi
    
    # Попытка определить SID из процессов Oracle
    local running_sid=$(ps aux | grep "[o]ra_pmon" | grep -v grep | awk '{print $NF}' | sed 's/ora_pmon_//' | head -1)
    if [[ -n "$running_sid" ]]; then
        ORACLE_SID="$running_sid"
        log "Oracle SID определен из процессов: $ORACLE_SID"
        return
    fi
    
    # Попытка определить SID из listener
    if [[ -f "$ORACLE_HOME/bin/lsnrctl" ]]; then
        local listener_sid=$(sudo -u "$ORACLE_USER" bash -c "export ORACLE_HOME=$ORACLE_HOME; $ORACLE_HOME/bin/lsnrctl status" 2>/dev/null | grep "Service" | grep -E "orcl|prod|dev|test" | head -1 | awk '{print $1}' | cut -d'.' -f1)
        if [[ -n "$listener_sid" ]]; then
            ORACLE_SID="$listener_sid"
            log "Oracle SID определен из listener: $ORACLE_SID"
            return
        fi
    fi
    
    # Запрос SID у пользователя
    echo -e "${BLUE}Oracle SID не определен автоматически. Введите Oracle SID:${NC}"
    read -p "> " ORACLE_SID
    
    if [[ -z "$ORACLE_SID" ]]; then
        log_warning "Oracle SID не указан, используется значение по умолчанию: orcl"
        ORACLE_SID="orcl"
    fi
    
    log "Oracle SID: $ORACLE_SID"
}

# Проверка пользователей и групп
check_users_groups() {
    log "Проверка пользователей и групп Oracle..."
    
    local groups=("oinstall" "dba" "oper")
    local group_count=0
    
    for group in "${groups[@]}"; do
        if getent group "$group" >/dev/null; then
            log "Группа $group: Существует ✓"
            ((group_count++))
        else
            log_error "Группа $group: НЕ НАЙДЕНА"
        fi
    done
    
    if id "$ORACLE_USER" >/dev/null 2>&1; then
        log "Пользователь $ORACLE_USER: Существует ✓"
        
        # Проверка групп пользователя
        local user_groups=$(groups "$ORACLE_USER")
        if echo "$user_groups" | grep -q "oinstall"; then
            log "Пользователь $ORACLE_USER в группе oinstall ✓"
        else
            log_warning "Пользователь $ORACLE_USER НЕ в группе oinstall"
        fi
    else
        log_error "Пользователь $ORACLE_USER: НЕ НАЙДЕН"
    fi
    
    log_info "Найдено групп Oracle: $group_count/${#groups[@]}"
}

# Проверка директорий Oracle
check_directories() {
    log "Проверка директорий Oracle..."
    
    local directories=("$ORACLE_BASE" "$ORACLE_HOME" "/opt/oraInventory" "/opt/oracle/admin" "/opt/oracle/flash_recovery_area" "/opt/oracle/oradata")
    local dir_count=0
    
    for dir in "${directories[@]}"; do
        if [[ -d "$dir" ]]; then
            local owner=$(stat -c '%U:%G' "$dir")
            local perms=$(stat -c '%a' "$dir")
            log "Директория $dir: Существует (владелец: $owner, права: $perms) ✓"
            ((dir_count++))
        else
            log_error "Директория $dir: НЕ НАЙДЕНА"
        fi
    done
    
    log_info "Найдено директорий Oracle: $dir_count/${#directories[@]}"
}

# Проверка переменных окружения
check_environment() {
    log "Проверка переменных окружения Oracle..."
    
    # Проверка .bashrc пользователя oracle
    local bashrc="/home/$ORACLE_USER/.bashrc"
    if [[ -f "$bashrc" ]]; then
        log "Файл .bashrc пользователя oracle: Найден ✓"
        
        # Проверка переменных
        local vars=("ORACLE_BASE" "ORACLE_HOME" "ORACLE_SID" "PATH" "LD_LIBRARY_PATH")
        local var_count=0
        
        for var in "${vars[@]}"; do
            if grep -q "export $var" "$bashrc"; then
                log "Переменная $var: Настроена ✓"
                ((var_count++))
            else
                log_warning "Переменная $var: НЕ НАСТРОЕНА"
            fi
        done
        
        log_info "Настроено переменных: $var_count/${#vars[@]}"
    else
        log_error "Файл .bashrc пользователя oracle: НЕ НАЙДЕН"
    fi
}

# Проверка параметров ядра
check_kernel_params() {
    log "Проверка параметров ядра..."
    
    local params=("kernel.sem" "kernel.shmall" "kernel.shmmax" "kernel.shmmni" "fs.file-max")
    local param_count=0
    
    for param in "${params[@]}"; do
        local value=$(sysctl -n "$param" 2>/dev/null || echo "не установлен")
        if [[ "$value" != "не установлен" ]]; then
            log "Параметр $param: $value ✓"
            ((param_count++))
        else
            log_warning "Параметр $param: НЕ УСТАНОВЛЕН"
        fi
    done
    
    log_info "Настроено параметров ядра: $param_count/${#params[@]}"
}

# Проверка лимитов системы
check_limits() {
    log "Проверка лимитов системы..."
    
    local limits_file="/etc/security/limits.conf"
    if [[ -f "$limits_file" ]]; then
        local oracle_limits=$(grep -c "^$ORACLE_USER" "$limits_file" || echo "0")
        if [[ $oracle_limits -gt 0 ]]; then
            log "Лимиты для пользователя $ORACLE_USER: Настроены ($oracle_limits записей) ✓"
        else
            log_warning "Лимиты для пользователя $ORACLE_USER: НЕ НАСТРОЕНЫ"
        fi
    else
        log_error "Файл лимитов: НЕ НАЙДЕН"
    fi
}

# Проверка установленных пакетов
check_packages() {
    log "Проверка установленных пакетов..."
    
    local packages=("libaio1" "libaio-dev" "libelf1" "libelf-dev" "libstdc++6" "libstdc++6-dev" "libx11-dev" "unixodbc" "unixodbc-dev" "sysstat")
    local package_count=0
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii.*$package"; then
            log "Пакет $package: Установлен ✓"
            ((package_count++))
        else
            log_warning "Пакет $package: НЕ УСТАНОВЛЕН"
        fi
    done
    
    log_info "Установлено пакетов: $package_count/${#packages[@]}"
}

# Проверка процессов Oracle
check_processes() {
    log "Проверка процессов Oracle..."
    
    local oracle_processes=$(ps aux | grep -c "[o]racle" || echo "0")
    if [[ $oracle_processes -gt 0 ]]; then
        log "Процессы Oracle: Найдено $oracle_processes процессов ✓"
        
        # Показать основные процессы
        ps aux | grep "[o]racle" | head -5 | while read line; do
            log_info "  $line"
        done
    else
        log_warning "Процессы Oracle: НЕ НАЙДЕНЫ"
    fi
}

# Проверка портов Oracle
check_ports() {
    log "Проверка портов Oracle..."
    
    # Проверка порта 1521 (Oracle Database)
    if netstat -tlnp 2>/dev/null | grep -q ":1521 "; then
        log "Порт 1521 (Oracle Database): Открыт ✓"
    else
        log_warning "Порт 1521 (Oracle Database): НЕ ОТКРЫТ"
    fi
    
    # Проверка порта 1158 (Oracle EM)
    if netstat -tlnp 2>/dev/null | grep -q ":1158 "; then
        log "Порт 1158 (Oracle EM): Открыт ✓"
    else
        log_warning "Порт 1158 (Oracle EM): НЕ ОТКРЫТ"
    fi
}

# Проверка listener
check_listener() {
    log "Проверка Oracle Listener..."
    
    # Проверка статуса listener от имени oracle
    if sudo -u "$ORACLE_USER" bash -c "export ORACLE_HOME=$ORACLE_HOME; $ORACLE_HOME/bin/lsnrctl status" >/dev/null 2>&1; then
        log "Oracle Listener: Активен ✓"
        
        # Получение статуса listener
        local listener_status=$(sudo -u "$ORACLE_USER" bash -c "export ORACLE_HOME=$ORACLE_HOME; $ORACLE_HOME/bin/lsnrctl status" 2>/dev/null | grep "STATUS" | head -1 || echo "статус неизвестен")
        log_info "  $listener_status"
    else
        log_warning "Oracle Listener: НЕ АКТИВЕН"
    fi
}

# Проверка базы данных
check_database() {
    log "Проверка базы данных Oracle..."
    
    # Проверка подключения к базе
    if sudo -u "$ORACLE_USER" bash -c "export ORACLE_HOME=$ORACLE_HOME; export ORACLE_SID=$ORACLE_SID; echo 'SELECT status FROM v\$instance;' | $ORACLE_HOME/bin/sqlplus -s / as sysdba" >/dev/null 2>&1; then
        log "База данных Oracle: Доступна ✓"
        
        # Получение статуса базы
        local db_status=$(sudo -u "$ORACLE_USER" bash -c "export ORACLE_HOME=$ORACLE_HOME; export ORACLE_SID=$ORACLE_SID; echo 'SELECT status FROM v\$instance;' | $ORACLE_HOME/bin/sqlplus -s / as sysdba" 2>/dev/null | grep -E "OPEN|MOUNTED|STARTED" | head -1 || echo "статус неизвестен")
        log_info "  Статус базы: $db_status"
    else
        log_warning "База данных Oracle: НЕ ДОСТУПНА"
    fi
}

# Проверка логов Oracle
check_logs() {
    log "Проверка логов Oracle..."
    
    local log_dirs=("/opt/oracle/diag/rdbms/$ORACLE_SID/$ORACLE_SID/trace" "/opt/oracle/diag/tnslsnr/$(hostname)/listener/trace")
    local log_count=0
    
    for log_dir in "${log_dirs[@]}"; do
        if [[ -d "$log_dir" ]]; then
            log "Директория логов $log_dir: Найдена ✓"
            
            # Проверка основных логов
            local alert_log="$log_dir/alert_$ORACLE_SID.log"
            if [[ -f "$alert_log" ]]; then
                local log_size=$(du -h "$alert_log" | cut -f1)
                log_info "  Alert log: $alert_log (размер: $log_size)"
            fi
            
            ((log_count++))
        else
            log_warning "Директория логов $log_dir: НЕ НАЙДЕНА"
        fi
    done
    
    log_info "Найдено директорий логов: $log_count/${#log_dirs[@]}"
}

# Создание отчета о проверке
create_check_report() {
    log "Создание отчета о проверке..."
    
    local REPORT_FILE="/root/oracle-check-report-$(date '+%Y-%m-%d').txt"
    
    cat > "$REPORT_FILE" << EOF
=============================================================================
ОТЧЕТ О ПРОВЕРКЕ ORACLE DATABASE 11.2.0.4.0
Дата проверки: $(date)
Версия скрипта: 1.0
=============================================================================

СИСТЕМНАЯ ИНФОРМАЦИЯ:
- ОС: $(lsb_release -d | cut -f2)
- Ядро: $(uname -r)
- Архитектура: $(uname -m)
- Память: $(free -h | grep Mem | awk '{print $2}')

ПЕРЕМЕННЫЕ ORACLE:
- ORACLE_BASE: $ORACLE_BASE
- ORACLE_HOME: $ORACLE_HOME
- ORACLE_SID: $ORACLE_SID
- ORACLE_USER: $ORACLE_USER

ПРОЦЕССЫ ORACLE:
$(ps aux | grep oracle | grep -v grep || echo "Процессы Oracle не найдены")

ПОРТЫ ORACLE:
$(netstat -tlnp | grep -E ":1521|:1158" || echo "Порты Oracle не открыты")

СТАТУС LISTENER:
$(sudo -u $ORACLE_USER bash -c "export ORACLE_HOME=$ORACLE_HOME; $ORACLE_HOME/bin/lsnrctl status" 2>/dev/null || echo "Listener недоступен")

СТАТУС БАЗЫ ДАННЫХ:
$(sudo -u $ORACLE_USER bash -c "export ORACLE_HOME=$ORACLE_HOME; export ORACLE_SID=$ORACLE_SID; echo 'SELECT instance_name, status FROM v\$instance;' | $ORACLE_HOME/bin/sqlplus -s / as sysdba" 2>/dev/null || echo "База данных недоступна")

РЕКОМЕНДАЦИИ:
1. Проверьте логи Oracle на наличие ошибок
2. Убедитесь в корректности переменных окружения
3. Проверьте права доступа к файлам Oracle
4. Настройте автоматический запуск Oracle при загрузке системы

ЛОГИ ПРОВЕРКИ:
- Основной лог: $LOG_FILE
- Отчет: $REPORT_FILE

=============================================================================
EOF

    log "Отчет о проверке создан: $REPORT_FILE"
}

# Основная функция
main() {
    log "Начинаем проверку установки Oracle Database 11.2.0.4.0..."
    
    # Определение SID Oracle
    detect_oracle_sid
    
    # Проверки
    check_users_groups
    check_directories
    check_environment
    check_kernel_params
    check_limits
    check_packages
    check_processes
    check_ports
    check_listener
    check_database
    check_logs
    
    # Создание отчета
    create_check_report
    
    log "Проверка Oracle завершена!"
    log "Подробный отчет сохранен в /root/oracle-check-report-$(date '+%Y-%m-%d').txt"
}

# Запуск основной функции
main "$@"
