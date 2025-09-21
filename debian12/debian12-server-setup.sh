#!/bin/bash

# =============================================================================
# Скрипт настройки и защиты сервера Debian 12
# Автор: DevOps Expert Team
# Версия: 1.1
# Описание: Комплексная настройка сервера Debian 12 с максимальной защитой
# =============================================================================

# Настройка кодировки UTF-8
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8

set -euo pipefail  # Прерывание при ошибках и неопределенных переменных

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Логирование
LOG_FILE="/var/log/debian12-setup.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Переменные для пользователя администратора
ADMIN_USERNAME=""
ADMIN_PASSWORD=""

# Функция логирования
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

# Функция ввода имени администратора
get_admin_username() {
    log "Настройка пользователя администратора..."
    
    while true; do
        echo -e "${BLUE}Введите имя пользователя администратора:${NC}"
        read -p "> " username
        
        # Проверка на пустое значение
        if [[ -z "$username" ]]; then
            log_error "Имя пользователя не может быть пустым"
            continue
        fi
        
        # Проверка на допустимые символы (только буквы, цифры, дефис, подчеркивание)
        if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            log_error "Имя пользователя может содержать только буквы, цифры, дефис и подчеркивание"
            continue
        fi
        
        # Проверка длины (3-32 символа)
        if [[ ${#username} -lt 3 ]] || [[ ${#username} -gt 32 ]]; then
            log_error "Имя пользователя должно быть от 3 до 32 символов"
            continue
        fi
        
        # Проверка на зарезервированные имена
        local reserved_names=("root" "admin" "administrator" "daemon" "bin" "sys" "sync" "games" "man" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-timesync" "systemd-network" "systemd-resolve" "systemd-bus-proxy" "messagebus" "syslog" "_apt" "uuidd" "tcpdump" "tss" "landscape" "pollinate" "sshd" "systemd-coredump")
        
        for reserved in "${reserved_names[@]}"; do
            if [[ "$username" == "$reserved" ]]; then
                log_error "Имя '$username' зарезервировано системой"
                continue 2
            fi
        done
        
        # Проверка существования пользователя
        if id "$username" &>/dev/null; then
            log_error "Пользователь '$username' уже существует"
            continue
        fi
        
        ADMIN_USERNAME="$username"
        log "Имя пользователя администратора: $ADMIN_USERNAME"
        break
    done
}

# Функция ввода пароля администратора
get_admin_password() {
    log "Настройка пароля администратора..."
    
    while true; do
        echo -e "${BLUE}Введите пароль для пользователя '$ADMIN_USERNAME':${NC}"
        read -s -p "> " password
        echo
        
        # Проверка на пустое значение
        if [[ -z "$password" ]]; then
            log_error "Пароль не может быть пустым"
            continue
        fi
        
        # Проверка длины (минимум 8 символов)
        if [[ ${#password} -lt 8 ]]; then
            log_error "Пароль должен содержать минимум 8 символов"
            continue
        fi
        
        # Проверка сложности пароля
        local has_upper=false
        local has_lower=false
        local has_digit=false
        local has_special=false
        
        if [[ "$password" =~ [A-Z] ]]; then has_upper=true; fi
        if [[ "$password" =~ [a-z] ]]; then has_lower=true; fi
        if [[ "$password" =~ [0-9] ]]; then has_digit=true; fi
        if [[ "$password" =~ [^a-zA-Z0-9] ]]; then has_special=true; fi
        
        local complexity_score=0
        [[ "$has_upper" == true ]] && ((complexity_score++))
        [[ "$has_lower" == true ]] && ((complexity_score++))
        [[ "$has_digit" == true ]] && ((complexity_score++))
        [[ "$has_special" == true ]] && ((complexity_score++))
        
        if [[ $complexity_score -lt 3 ]]; then
            log_warning "Пароль должен содержать минимум 3 из 4 типов символов:"
            log_warning "  - Заглавные буквы (A-Z)"
            log_warning "  - Строчные буквы (a-z)"
            log_warning "  - Цифры (0-9)"
            log_warning "  - Специальные символы (!@#$%^&*)"
            continue
        fi
        
        # Подтверждение пароля
        echo -e "${BLUE}Подтвердите пароль:${NC}"
        read -s -p "> " password_confirm
        echo
        
        if [[ "$password" != "$password_confirm" ]]; then
            log_error "Пароли не совпадают"
            continue
        fi
        
        ADMIN_PASSWORD="$password"
        log "Пароль для пользователя '$ADMIN_USERNAME' установлен"
        break
    done
}

# Функция настройки пользователя администратора
setup_admin_user() {
    log "Настройка пользователя администратора..."
    
    # Получение данных от пользователя
    get_admin_username
    get_admin_password
    
    # Создание пользователя
    log "Создание пользователя '$ADMIN_USERNAME'..."
    useradd -m -s /bin/bash "$ADMIN_USERNAME"
    usermod -aG sudo "$ADMIN_USERNAME"
    
    # Установка пароля
    echo "$ADMIN_USERNAME:$ADMIN_PASSWORD" | chpasswd
    
    # Создание директории .ssh
    mkdir -p "/home/$ADMIN_USERNAME/.ssh"
    chmod 700 "/home/$ADMIN_USERNAME/.ssh"
    chown "$ADMIN_USERNAME:$ADMIN_USERNAME" "/home/$ADMIN_USERNAME/.ssh"
    
    # Создание файла .bashrc с полезными алиасами
    cat >> "/home/$ADMIN_USERNAME/.bashrc" << EOF

# Полезные алиасы для администратора
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias path='echo -e \${PATH//:/\\n}'
alias du='du -kh'
alias df='df -kTh'
alias free='free -m'
alias ps='ps aux'
alias top='htop'

# Алиас для проверки безопасности
alias security-check='/usr/local/bin/security-check.sh'

# Цветной вывод для ls
export LS_OPTIONS='--color=auto'
eval "\$(dircolors)"
alias ls='ls \$LS_OPTIONS'
EOF

    chown "$ADMIN_USERNAME:$ADMIN_USERNAME" "/home/$ADMIN_USERNAME/.bashrc"
    
    log "Пользователь '$ADMIN_USERNAME' успешно создан"
    log_info "Пользователь добавлен в группу sudo"
    log_info "Директория SSH создана: /home/$ADMIN_USERNAME/.ssh"
    log_info "Полезные алиасы добавлены в .bashrc"
}

# Проверка и настройка локали
setup_locale() {
    log "Настройка локали UTF-8..."
    
    # Проверка наличия русской локали
    if ! locale -a | grep -q "ru_RU.utf8"; then
        log "Установка русской локали..."
        apt update -y
        apt install -y locales
        sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
        locale-gen
    fi
    
    # Установка локали для текущей сессии
    export LANG=ru_RU.UTF-8
    export LC_ALL=ru_RU.UTF-8
    
    log "Локаль UTF-8 настроена"
}

# Проверка прав root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен запускаться с правами root"
        exit 1
    fi
}

# Проверка версии Debian
check_debian_version() {
    if [[ ! -f /etc/debian_version ]]; then
        log_error "Этот скрипт предназначен только для Debian"
        exit 1
    fi
    
    DEBIAN_VERSION=$(cat /etc/debian_version)
    log_info "Обнаружена версия Debian: $DEBIAN_VERSION"
    
    if [[ ! "$DEBIAN_VERSION" =~ ^12 ]]; then
        log_warning "Скрипт оптимизирован для Debian 12, но будет продолжен"
    fi
}

# Обновление системы
update_system() {
    log "Начинаем обновление системы..."
    
    # Обновление списка пакетов
    apt update -y
    
    # Обновление установленных пакетов
    apt upgrade -y
    
    # Очистка кэша
    apt autoremove -y
    apt autoclean
    
    log "Система успешно обновлена"
}

# Исправление проблем с пакетами
fix_package_conflicts() {
    log "Исправление конфликтов пакетов..."
    
    # Удаление проблемных пакетов, если они установлены
    if dpkg -l | grep -q "^ii.*ntp "; then
        log "Удаление старого пакета ntp..."
        apt remove -y ntp || true
    fi
    
    # Очистка зависимостей
    apt autoremove -y
    apt autoclean
    
    # Исправление сломанных пакетов
    apt --fix-broken install -y || log_warning "Некоторые пакеты не удалось исправить"
    
    log "Конфликты пакетов исправлены"
}

# Установка базовых пакетов
install_base_packages() {
    log "Установка базовых пакетов..."
    
    # Базовые утилиты
    apt install -y \
        curl \
        wget \
        git \
        vim \
        nano \
        htop \
        tree \
        unzip \
        zip \
        rsync \
        net-tools \
        dnsutils \
        telnet \
        tcpdump \
        ufw \
        fail2ban \
        logwatch \
        aide \
        rkhunter \
        chkrootkit \
        clamav \
        clamav-daemon \
        cron \
        systemd-timesyncd \
        openssh-server \
        sudo \
        auditd \
        apparmor \
        apparmor-utils \
        unattended-upgrades \
        apt-listchanges \
        debconf-utils \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
    
    # Установка iptables-persistent отдельно (может конфликтовать с ufw)
    if ! dpkg -l | grep -q "iptables-persistent"; then
        log "Установка iptables-persistent..."
        apt install -y iptables-persistent || log_warning "iptables-persistent не установлен (может конфликтовать с ufw)"
    fi
    
    log "Базовые пакеты установлены"
}

# Настройка SSH
configure_ssh() {
    log "Настройка SSH..."
    
    # Создание резервной копии конфигурации
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Настройка SSH
    cat > /etc/ssh/sshd_config << 'EOF'
# Настройки безопасности SSH
Port 22
Protocol 2
AddressFamily inet

# Аутентификация
LoginGraceTime 60
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 3

# Пользователи и группы
AllowUsers $ADMIN_USERNAME
DenyUsers root

# Пароли и ключи
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Настройки безопасности
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UsePAM yes

# Настройки сессии
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Дополнительные настройки безопасности
ClientAliveInterval 300
ClientAliveCountMax 2
TCPKeepAlive yes
Compression delayed
EOF

    # Перезапуск SSH
    systemctl restart ssh
    systemctl enable ssh
    
    log "SSH настроен и перезапущен"
}

# Создание пользователя администратора

# Настройка файрвола
configure_firewall() {
    log "Настройка файрвола UFW..."
    
    # Сброс правил
    ufw --force reset
    
    # Политики по умолчанию
    ufw default deny incoming
    ufw default allow outgoing
    
    # Разрешенные порты
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    
    # Включение файрвола
    ufw --force enable
    
    # Проверка статуса
    ufw status verbose
    
    log "Файрвол UFW настроен и включен"
}

# Настройка fail2ban
configure_fail2ban() {
    log "Настройка fail2ban..."
    
    # Создание конфигурации для SSH
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

    # Перезапуск fail2ban
    systemctl restart fail2ban
    systemctl enable fail2ban
    
    log "fail2ban настроен и запущен"
}

# Настройка автоматических обновлений
configure_auto_updates() {
    log "Настройка автоматических обновлений..."
    
    # Конфигурация автоматических обновлений
    cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

    # Включение автоматических обновлений
    cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

    # Включение службы
    systemctl enable unattended-upgrades
    systemctl start unattended-upgrades
    
    log "Автоматические обновления настроены"
}

# Настройка мониторинга системы
configure_monitoring() {
    log "Настройка мониторинга системы..."
    
    # Создание скрипта мониторинга
    cat > /usr/local/bin/system-monitor.sh << 'EOF'
#!/bin/bash

# Скрипт мониторинга системы
LOG_FILE="/var/log/system-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Проверка использования диска
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "[$DATE] WARNING: Диск заполнен на ${DISK_USAGE}%" >> "$LOG_FILE"
fi

# Проверка использования памяти
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ "$MEMORY_USAGE" -gt 80 ]; then
    echo "[$DATE] WARNING: Память используется на ${MEMORY_USAGE}%" >> "$LOG_FILE"
fi

# Проверка загрузки системы
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
if (( $(echo "$LOAD_AVG > 2.0" | bc -l) )); then
    echo "[$DATE] WARNING: Высокая загрузка системы: $LOAD_AVG" >> "$LOG_FILE"
fi
EOF

    chmod +x /usr/local/bin/system-monitor.sh
    
    # Добавление в cron (каждые 5 минут)
    echo "*/5 * * * * root /usr/local/bin/system-monitor.sh" >> /etc/crontab
    
    log "Мониторинг системы настроен"
}

# Настройка логирования
configure_logging() {
    log "Настройка системы логирования..."
    
    # Настройка rsyslog
    cat > /etc/rsyslog.d/50-security.conf << 'EOF'
# Логирование безопасности
auth,authpriv.*                 /var/log/auth.log
*.*;auth,authpriv.none          -/var/log/syslog
kern.*                          -/var/log/kern.log
mail.*                          -/var/log/mail.log
cron.*                          -/var/log/cron.log
daemon.*                        -/var/log/daemon.log
EOF

    # Настройка logrotate
    cat > /etc/logrotate.d/security << 'EOF'
/var/log/auth.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 root adm
}

/var/log/fail2ban.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 root adm
}
EOF

    # Перезапуск rsyslog
    systemctl restart rsyslog
    
    log "Система логирования настроена"
}

# Настройка резервного копирования
configure_backup() {
    log "Настройка резервного копирования..."
    
    # Создание скрипта резервного копирования
    cat > /usr/local/bin/backup-system.sh << 'EOF'
#!/bin/bash

# Скрипт резервного копирования
BACKUP_DIR="/backup"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_FILE="system-backup-$DATE.tar.gz"

# Создание директории для резервных копий
mkdir -p "$BACKUP_DIR"

# Создание резервной копии важных конфигураций
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    /etc \
    /home \
    /root \
    /var/log \
    /usr/local/bin \
    --exclude=/etc/ssh/ssh_host_* \
    --exclude=/var/log/*.log

# Удаление старых резервных копий (старше 7 дней)
find "$BACKUP_DIR" -name "system-backup-*.tar.gz" -mtime +7 -delete

echo "Резервная копия создана: $BACKUP_FILE"
EOF

    chmod +x /usr/local/bin/backup-system.sh
    
    # Добавление в cron (ежедневно в 2:00)
    echo "0 2 * * * root /usr/local/bin/backup-system.sh" >> /etc/crontab
    
    log "Резервное копирование настроено"
}

# Настройка безопасности
configure_security() {
    log "Настройка дополнительных мер безопасности..."
    
    # Настройка AppArmor
    systemctl enable apparmor
    systemctl start apparmor
    
    # Настройка auditd
    cat > /etc/audit/rules.d/audit.rules << 'EOF'
# Мониторинг системных вызовов
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change

# Мониторинг сетевых событий
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale

# Мониторинг файловой системы
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Мониторинг сетевых конфигураций
-w /etc/network/ -p wa -k network-config
-w /etc/hosts -p wa -k network-config
-w /etc/hostname -p wa -k network-config
EOF

    systemctl enable auditd
    systemctl start auditd
    
    # Настройка лимитов системы
    cat > /etc/security/limits.conf << 'EOF'
# Лимиты для безопасности
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF

    log "Дополнительные меры безопасности настроены"
}

# Настройка сети
configure_network() {
    log "Настройка сетевых параметров..."
    
    # Оптимизация сетевых параметров
    cat > /etc/sysctl.d/99-security.conf << 'EOF'
# Настройки безопасности сети
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Настройки IPv6
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Настройки производительности
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
EOF

    # Применение настроек
    sysctl -p /etc/sysctl.d/99-security.conf
    
    log "Сетевые параметры настроены"
}

# Настройка времени
configure_time() {
    log "Настройка синхронизации времени..."
    
    # Настройка systemd-timesyncd (современная альтернатива NTP)
    cat > /etc/systemd/timesyncd.conf << 'EOF'
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
FallbackNTP=time.google.com time.cloudflare.com
PollIntervalMinSec=32
PollIntervalMaxSec=2048
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
EOF

    # Включение службы времени
    systemctl enable systemd-timesyncd
    systemctl start systemd-timesyncd
    
    # Синхронизация времени
    timedatectl set-ntp true
    
    # Проверка статуса
    timedatectl status
    
    log "Синхронизация времени настроена (systemd-timesyncd)"
}

# Создание отчета о настройке
create_setup_report() {
    log "Создание отчета о настройке..."
    
    REPORT_FILE="/root/setup-report-$(date '+%Y-%m-%d').txt"
    
    cat > "$REPORT_FILE" << EOF
=============================================================================
ОТЧЕТ О НАСТРОЙКЕ СЕРВЕРА DEBIAN 12
Дата настройки: $(date)
Версия скрипта: 1.0
=============================================================================

СИСТЕМНАЯ ИНФОРМАЦИЯ:
- Версия ОС: $(cat /etc/debian_version)
- Ядро: $(uname -r)
- Архитектура: $(uname -m)
- Время работы: $(uptime -p)

УСТАНОВЛЕННЫЕ ПАКЕТЫ БЕЗОПАСНОСТИ:
- fail2ban: $(dpkg -l | grep fail2ban | awk '{print $3}')
- ufw: $(dpkg -l | grep ufw | awk '{print $3}')
- aide: $(dpkg -l | grep aide | awk '{print $3}')
- rkhunter: $(dpkg -l | grep rkhunter | awk '{print $3}')
- chkrootkit: $(dpkg -l | grep chkrootkit | awk '{print $3}')
- clamav: $(dpkg -l | grep clamav | awk '{print $3}')

НАСТРОЙКИ БЕЗОПАСНОСТИ:
- SSH: Настроен, root отключен
- Файрвол: UFW включен
- fail2ban: Настроен для SSH
- Автообновления: Включены
- AppArmor: Включен
- auditd: Настроен

СЕТЕВЫЕ НАСТРОЙКИ:
- IP адрес: $(hostname -I)
- Шлюз: $(ip route | grep default | awk '{print $3}')
- DNS: $(cat /etc/resolv.conf | grep nameserver | head -1 | awk '{print $2}')

СЛУЖБЫ:
$(systemctl list-unit-files --state=enabled | grep -E "(ssh|ufw|fail2ban|ntp|auditd|apparmor)")

ПОЛЬЗОВАТЕЛЬ АДМИНИСТРАТОРА:
- Имя пользователя: $ADMIN_USERNAME
- Группа sudo: Да
- SSH директория: /home/$ADMIN_USERNAME/.ssh

РЕКОМЕНДАЦИИ:
1. Настройте SSH ключи для пользователя $ADMIN_USERNAME
2. Регулярно проверяйте логи безопасности
3. Обновите базы данных антивируса: freshclam
4. Запустите проверку на rootkit: rkhunter --check
5. Регулярно меняйте пароли пользователей

ЛОГИ НАСТРОЙКИ:
- Основной лог: $LOG_FILE
- Отчет: $REPORT_FILE

=============================================================================
EOF

    log "Отчет создан: $REPORT_FILE"
}

# Основная функция
main() {
    log "Начинаем настройку сервера Debian 12..."
    
    # Проверки
    check_root
    check_debian_version
    setup_locale
    
    # Основные настройки
    update_system
    fix_package_conflicts
    install_base_packages
    setup_admin_user
    configure_ssh
    configure_firewall
    configure_fail2ban
    configure_auto_updates
    configure_monitoring
    configure_logging
    configure_backup
    configure_security
    configure_network
    configure_time
    
    # Создание отчета
    create_setup_report
    
    log "Настройка сервера завершена успешно!"
    log "Перезагрузите сервер для применения всех изменений: reboot"
    
    # Предложение перезагрузки
    read -p "Перезагрузить сервер сейчас? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Перезагружаем сервер..."
        reboot
    else
        log "Не забудьте перезагрузить сервер позже для применения всех изменений"
    fi
}

# Запуск основной функции
main "$@"
