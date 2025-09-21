#!/bin/bash

# =============================================================================
# Скрипт быстрой установки с GitHub
# Автор: DevOps Expert Team
# Версия: 1.1
# Описание: Быстрая установка и настройка сервера Debian 12 с GitHub
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

# Конфигурация
GITHUB_REPO="your-username/your-repo"  # Замените на ваш репозиторий
SCRIPT_URL="https://raw.githubusercontent.com/$GITHUB_REPO/main/debian12/debian12-server-setup.sh"
SECURITY_CHECK_URL="https://raw.githubusercontent.com/$GITHUB_REPO/main/debian12/security-check.sh"

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

# Проверка подключения к интернету
check_internet() {
    log "Проверка подключения к интернету..."
    
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_error "Нет подключения к интернету"
        exit 1
    fi
    
    log "Подключение к интернету: OK"
}

# Проверка версии Debian
check_debian() {
    if [[ ! -f /etc/debian_version ]]; then
        log_error "Этот скрипт предназначен только для Debian"
        exit 1
    fi
    
    local debian_version=$(cat /etc/debian_version)
    log_info "Версия Debian: $debian_version"
    
    if [[ ! "$debian_version" =~ ^12 ]]; then
        log_warning "Скрипт оптимизирован для Debian 12"
        read -p "Продолжить установку? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Установка необходимых пакетов
install_prerequisites() {
    log "Установка необходимых пакетов..."
    
    apt update -y
    apt install -y curl wget git ca-certificates
}

# Скачивание и запуск основного скрипта
download_and_run_setup() {
    log "Скачивание скрипта настройки..."
    
    local setup_script="/tmp/debian12-server-setup.sh"
    
    # Скачивание скрипта
    if curl -fsSL "$SCRIPT_URL" -o "$setup_script"; then
        log "Скрипт успешно скачан"
    else
        log_error "Ошибка скачивания скрипта"
        exit 1
    fi
    
    # Предоставление прав на выполнение
    chmod +x "$setup_script"
    
    # Запуск скрипта
    log "Запуск скрипта настройки..."
    "$setup_script"
}

# Скачивание скрипта проверки безопасности
download_security_check() {
    log "Скачивание скрипта проверки безопасности..."
    
    local security_script="/usr/local/bin/security-check.sh"
    
    if curl -fsSL "$SECURITY_CHECK_URL" -o "$security_script"; then
        chmod +x "$security_script"
        log "Скрипт проверки безопасности установлен: $security_script"
    else
        log_warning "Не удалось скачать скрипт проверки безопасности"
    fi
}

# Создание алиаса для проверки безопасности
create_security_alias() {
    log "Создание алиаса для проверки безопасности..."
    
    cat >> /root/.bashrc << 'EOF'

# Алиас для проверки безопасности
alias security-check='/usr/local/bin/security-check.sh'
EOF

    # Применение алиаса для текущей сессии
    alias security-check='/usr/local/bin/security-check.sh'
    
    log "Алиас 'security-check' создан"
}

# Создание скрипта обновления
create_update_script() {
    log "Создание скрипта обновления..."
    
    cat > /usr/local/bin/update-security-scripts.sh << EOF
#!/bin/bash

# Скрипт обновления скриптов безопасности
set -euo pipefail

GITHUB_REPO="$GITHUB_REPO"
SCRIPT_URL="$SCRIPT_URL"
SECURITY_CHECK_URL="$SECURITY_CHECK_URL"

echo "Обновление скриптов безопасности..."

# Обновление скрипта проверки безопасности
if curl -fsSL "\$SECURITY_CHECK_URL" -o /usr/local/bin/security-check.sh; then
    chmod +x /usr/local/bin/security-check.sh
    echo "Скрипт проверки безопасности обновлен"
else
    echo "Ошибка обновления скрипта проверки безопасности"
fi

echo "Обновление завершено"
EOF

    chmod +x /usr/local/bin/update-security-scripts.sh
    
    log "Скрипт обновления создан: /usr/local/bin/update-security-scripts.sh"
}

# Создание информационного файла
create_info_file() {
    log "Создание информационного файла..."
    
    cat > /root/debian12-setup-info.txt << EOF
=============================================================================
ИНФОРМАЦИЯ О НАСТРОЙКЕ СЕРВЕРА DEBIAN 12
Дата установки: $(date)
Версия скрипта: 1.0
GitHub репозиторий: https://github.com/$GITHUB_REPO
=============================================================================

УСТАНОВЛЕННЫЕ СКРИПТЫ:
- Основной скрипт настройки: /tmp/debian12-server-setup.sh
- Скрипт проверки безопасности: /usr/local/bin/security-check.sh
- Скрипт обновления: /usr/local/bin/update-security-scripts.sh

КОМАНДЫ:
- Проверка безопасности: security-check
- Обновление скриптов: /usr/local/bin/update-security-scripts.sh
- Повторная настройка: curl -fsSL $SCRIPT_URL | bash

ЛОГИ:
- Лог установки: /var/log/debian12-setup.log
- Лог проверки безопасности: /var/log/security-check.log

ОТЧЕТЫ:
- Отчет настройки: /root/setup-report-$(date '+%Y-%m-%d').txt
- Отчет безопасности: /root/security-report-$(date '+%Y-%m-%d').txt

РЕКОМЕНДАЦИИ:
1. Измените пароль пользователя admin
2. Настройте SSH ключи
3. Запустите проверку безопасности: security-check
4. Регулярно обновляйте систему

=============================================================================
EOF

    log "Информационный файл создан: /root/debian12-setup-info.txt"
}

# Основная функция
main() {
    log "Начинаем быструю установку сервера Debian 12 с GitHub..."
    
    # Проверки
    check_root
    check_internet
    check_debian
    
    # Установка
    install_prerequisites
    download_and_run_setup
    download_security_check
    create_security_alias
    create_update_script
    create_info_file
    
    log "Быстрая установка завершена успешно!"
    log "Информация о настройке сохранена в /root/debian12-setup-info.txt"
    log "Для проверки безопасности запустите: security-check"
}

# Запуск основной функции
main "$@"

