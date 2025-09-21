#!/bin/bash

# =============================================================================
# Скрипт установки Oracle Database 11.2.0.4.0 через wget
# Автор: DevOps Expert Team
# Версия: 1.1
# Описание: Установка Oracle с параметрами через wget
# 
# Использование:
# wget -qO- "https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-with-wget.sh?sid=prod&db_name=PROD&sys_password=MyPass123!" | bash
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

# Парсинг URL параметров
parse_url_params() {
    log "Парсинг параметров из URL..."
    
    # Получение параметров из QUERY_STRING или аргументов командной строки
    if [[ -n "${QUERY_STRING:-}" ]]; then
        # Параметры из URL
        IFS='&' read -ra PARAMS <<< "$QUERY_STRING"
        for param in "${PARAMS[@]}"; do
            IFS='=' read -r key value <<< "$param"
            case "$key" in
                "sid")
                    ORACLE_SID_ENV="$value"
                    ;;
                "db_name")
                    ORACLE_DB_NAME_ENV="$value"
                    ;;
                "sys_password")
                    ORACLE_SYS_PASSWORD_ENV="$value"
                    ;;
                "system_password")
                    ORACLE_SYSTEM_PASSWORD_ENV="$value"
                    ;;
                "sysman_password")
                    ORACLE_SYSMAN_PASSWORD_ENV="$value"
                    ;;
                "dbsnmp_password")
                    ORACLE_DBSNMP_PASSWORD_ENV="$value"
                    ;;
            esac
        done
    else
        # Параметры из аргументов командной строки
        while [[ $# -gt 0 ]]; do
            case $1 in
                --sid)
                    ORACLE_SID_ENV="$2"
                    shift 2
                    ;;
                --db-name)
                    ORACLE_DB_NAME_ENV="$2"
                    shift 2
                    ;;
                --sys-password)
                    ORACLE_SYS_PASSWORD_ENV="$2"
                    shift 2
                    ;;
                --system-password)
                    ORACLE_SYSTEM_PASSWORD_ENV="$2"
                    shift 2
                    ;;
                --sysman-password)
                    ORACLE_SYSMAN_PASSWORD_ENV="$2"
                    shift 2
                    ;;
                --dbsnmp-password)
                    ORACLE_DBSNMP_PASSWORD_ENV="$2"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done
    fi
    
    # Отображение полученных параметров
    log_info "Полученные параметры:"
    log_info "SID: ${ORACLE_SID_ENV:-не задан}"
    log_info "DB Name: ${ORACLE_DB_NAME_ENV:-не задан}"
    log_info "SYS Password: ${ORACLE_SYS_PASSWORD_ENV:-не задан}"
    log_info "SYSTEM Password: ${ORACLE_SYSTEM_PASSWORD_ENV:-не задан}"
    log_info "SYSMAN Password: ${ORACLE_SYSMAN_PASSWORD_ENV:-не задан}"
    log_info "DBSNMP Password: ${ORACLE_DBSNMP_PASSWORD_ENV:-не задан}"
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
    
    # Парсинг параметров
    parse_url_params "$@"
    
    # Скачивание и запуск основного скрипта с параметрами
    log "Скачивание основного скрипта установки Oracle..."
    
    # Создание временного скрипта с параметрами
    cat > /tmp/oracle-install-temp.sh << 'EOF'
#!/bin/bash

# Переменные окружения из параметров
EOF

    # Добавление переменных окружения
    [[ -n "${ORACLE_SID_ENV:-}" ]] && echo "export ORACLE_SID_ENV='$ORACLE_SID_ENV'" >> /tmp/oracle-install-temp.sh
    [[ -n "${ORACLE_DB_NAME_ENV:-}" ]] && echo "export ORACLE_DB_NAME_ENV='$ORACLE_DB_NAME_ENV'" >> /tmp/oracle-install-temp.sh
    [[ -n "${ORACLE_SYS_PASSWORD_ENV:-}" ]] && echo "export ORACLE_SYS_PASSWORD_ENV='$ORACLE_SYS_PASSWORD_ENV'" >> /tmp/oracle-install-temp.sh
    [[ -n "${ORACLE_SYSTEM_PASSWORD_ENV:-}" ]] && echo "export ORACLE_SYSTEM_PASSWORD_ENV='$ORACLE_SYSTEM_PASSWORD_ENV'" >> /tmp/oracle-install-temp.sh
    [[ -n "${ORACLE_SYSMAN_PASSWORD_ENV:-}" ]] && echo "export ORACLE_SYSMAN_PASSWORD_ENV='$ORACLE_SYSMAN_PASSWORD_ENV'" >> /tmp/oracle-install-temp.sh
    [[ -n "${ORACLE_DBSNMP_PASSWORD_ENV:-}" ]] && echo "export ORACLE_DBSNMP_PASSWORD_ENV='$ORACLE_DBSNMP_PASSWORD_ENV'" >> /tmp/oracle-install-temp.sh

    # Добавление основного скрипта
    cat >> /tmp/oracle-install-temp.sh << 'EOF'

# Скачивание и выполнение основного скрипта через wget
wget -qO- https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-11g-install.sh | bash
EOF

    # Установка прав и запуск
    chmod +x /tmp/oracle-install-temp.sh
    bash /tmp/oracle-install-temp.sh
    
    # Очистка
    rm -f /tmp/oracle-install-temp.sh
    
    log "Установка Oracle завершена!"
}

# Запуск основной функции
main "$@"
