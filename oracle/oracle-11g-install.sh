#!/bin/bash

# =============================================================================
# Скрипт установки Oracle Database 11.2.0.4.0
# Автор: DevOps Expert Team
# Версия: 1.2
# Описание: Интерактивная установка Oracle 11g на Debian/Ubuntu
# 
# Использование:
# 1. Скачать скрипт: wget https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-11g-install.sh
# 2. Запустить: sudo bash oracle-11g-install.sh
# 3. Следовать интерактивным инструкциям
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

# Переменные Oracle
ORACLE_VERSION="11.2.0.4.0"
ORACLE_BASE="/opt/oracle"
ORACLE_HOME="/opt/oracle/product/11.2.0/dbhome_1"
ORACLE_SID=""
ORACLE_DB_NAME=""
ORACLE_USER="oracle"
ORACLE_GROUP="oinstall"
ORACLE_DBA_GROUP="dba"
ORACLE_OPER_GROUP="oper"
ORACLE_INVENTORY="/opt/oraInventory"

# Пароли Oracle
ORACLE_SYS_PASSWORD=""
ORACLE_SYSTEM_PASSWORD=""
ORACLE_SYSMAN_PASSWORD=""
ORACLE_DBSNMP_PASSWORD=""

# Функция ввода SID Oracle
get_oracle_sid() {
    log "Настройка Oracle SID..."
    
    while true; do
        echo -e "${BLUE}Введите Oracle SID (например: orcl, prod, dev):${NC}"
        read -p "> " sid
        
        # Проверка на пустое значение
        if [[ -z "$sid" ]]; then
            log_error "Oracle SID не может быть пустым"
            continue
        fi
        
        # Проверка на допустимые символы (только буквы, цифры, дефис, подчеркивание)
        if [[ ! "$sid" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            log_error "Oracle SID может содержать только буквы, цифры, дефис и подчеркивание"
            continue
        fi
        
        # Проверка длины (1-8 символов для Oracle SID)
        if [[ ${#sid} -lt 1 ]] || [[ ${#sid} -gt 8 ]]; then
            log_error "Oracle SID должен быть от 1 до 8 символов"
            continue
        fi
        
        # Проверка на зарезервированные имена
        local reserved_sids=("oracle" "orcl" "test" "demo" "sample" "temp" "backup" "archive")
        
        for reserved in "${reserved_sids[@]}"; do
            if [[ "$sid" == "$reserved" ]]; then
                log_warning "SID '$sid' является зарезервированным. Рекомендуется использовать уникальное имя"
                echo -e "${YELLOW}Продолжить с этим SID? (y/n):${NC}"
                read -p "> " confirm
                if [[ "$confirm" != "y" ]] && [[ "$confirm" != "Y" ]]; then
                    continue 2
                fi
            fi
        done
        
        ORACLE_SID="$sid"
        log "Oracle SID: $ORACLE_SID"
        break
    done
}

# Функция ввода названия базы данных
get_oracle_db_name() {
    log "Настройка названия базы данных..."
    
    while true; do
        echo -e "${BLUE}Введите название базы данных (например: PROD, DEV, TEST):${NC}"
        read -p "> " db_name
        
        # Проверка на пустое значение
        if [[ -z "$db_name" ]]; then
            log_error "Название базы данных не может быть пустым"
            continue
        fi
        
        # Проверка на допустимые символы (только буквы, цифры, дефис, подчеркивание)
        if [[ ! "$db_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            log_error "Название базы данных может содержать только буквы, цифры, дефис и подчеркивание"
            continue
        fi
        
        # Проверка длины (1-30 символов)
        if [[ ${#db_name} -lt 1 ]] || [[ ${#db_name} -gt 30 ]]; then
            log_error "Название базы данных должно быть от 1 до 30 символов"
            continue
        fi
        
        ORACLE_DB_NAME="$db_name"
        log "Название базы данных: $ORACLE_DB_NAME"
        break
    done
}

# Функция ввода пароля Oracle
get_oracle_password() {
    local password_type="$1"
    local password_var="$2"
    
    log "Настройка пароля для $password_type..."
    
    while true; do
        echo -e "${BLUE}Введите пароль для $password_type:${NC}"
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
        echo -e "${BLUE}Подтвердите пароль для $password_type:${NC}"
        read -s -p "> " password_confirm
        echo
        
        if [[ "$password" != "$password_confirm" ]]; then
            log_error "Пароли не совпадают"
            continue
        fi
        
        eval "$password_var='$password'"
        log "Пароль для $password_type установлен"
        break
    done
}

# Функция настройки Oracle конфигурации
setup_oracle_config() {
    log "Настройка конфигурации Oracle..."
    
    # Интерактивный ввод конфигурации
    get_oracle_sid
    get_oracle_db_name
    
    # Настройка паролей
    get_oracle_password "SYS" "ORACLE_SYS_PASSWORD"
    get_oracle_password "SYSTEM" "ORACLE_SYSTEM_PASSWORD"
    get_oracle_password "SYSMAN" "ORACLE_SYSMAN_PASSWORD"
    get_oracle_password "DBSNMP" "ORACLE_DBSNMP_PASSWORD"
    
    log "Конфигурация Oracle настроена:"
    log_info "SID: $ORACLE_SID"
    log_info "Название БД: $ORACLE_DB_NAME"
    log_info "Пароли установлены для всех пользователей"
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

# Создание пользователей и групп Oracle
create_oracle_users() {
    log "Создание пользователей и групп Oracle..."
    
    # Проверка доступности команд управления пользователями
    if ! command -v groupadd >/dev/null 2>&1; then
        log_error "Команда groupadd не найдена. Установка пакетов управления пользователями..."
        apt update -y
        apt install -y passwd
    fi
    
    # Создание групп
    for group in "$ORACLE_GROUP" "$ORACLE_DBA_GROUP" "$ORACLE_OPER_GROUP"; do
        if ! getent group "$group" >/dev/null; then
            if command -v groupadd >/dev/null 2>&1; then
                groupadd "$group"
                log "Группа $group создана"
            else
                log_error "Не удалось создать группу $group: команда groupadd недоступна"
                exit 1
            fi
        else
            log "Группа $group уже существует"
        fi
    done
    
    # Создание пользователя oracle
    if ! id "$ORACLE_USER" >/dev/null 2>&1; then
        useradd -g "$ORACLE_GROUP" -G "$ORACLE_DBA_GROUP,$ORACLE_OPER_GROUP" -m -s /bin/bash "$ORACLE_USER"
        log "Пользователь $ORACLE_USER создан"
    else
        log "Пользователь $ORACLE_USER уже существует"
    fi
}

# Установка необходимых пакетов
install_prerequisites() {
    log "Установка необходимых пакетов..."
    
    # Обновление системы
    apt update -y
    
    # Установка пакетов
    apt install -y \
        alien \
        binutils \
        build-essential \
        cpp \
        gcc \
        g++ \
        gawk \
        libaio1 \
        libaio-dev \
        libc6-dev \
        libelf1 \
        libelf-dev \
        libltdl3-dev \
        libstdc++6 \
        libstdc++6-dev \
        libx11-dev \
        libxau-dev \
        libxi-dev \
        libxmu-dev \
        libxtst-dev \
        make \
        rpm \
        sysstat \
        unixodbc \
        unixodbc-dev \
        x11-utils \
        libmotif4 \
        libmotif-dev \
        libc6 \
        libc6-dev \
        libstdc++5 \
        libstdc++6 \
        libaio1 \
        libaio-dev \
        libelf1 \
        libelf-dev \
        libltdl3-dev \
        libc6-dev \
        libstdc++6-dev \
        libx11-dev \
        libxau-dev \
        libxi-dev \
        libxmu-dev \
        libxtst-dev \
        libmotif4 \
        libmotif-dev \
        unixodbc \
        unixodbc-dev \
        sysstat \
        rpm \
        alien \
        build-essential \
        gcc \
        g++ \
        make \
        binutils \
        cpp \
        gawk \
        x11-utils
    
    log "Необходимые пакеты установлены"
}

# Настройка ядра
configure_kernel() {
    log "Настройка параметров ядра..."
    
    # Создание файла конфигурации ядра
    cat > /etc/sysctl.d/99-oracle.conf << 'EOF'
# Oracle Database 11g Kernel Parameters
kernel.sem = 250 32000 100 128
kernel.shmall = 2097152
kernel.shmmax = 4294967295
kernel.shmmni = 4096
kernel.msgmax = 65536
kernel.msgmnb = 65536
kernel.msgmni = 2878
fs.file-max = 6815744
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 3
EOF

    # Применение параметров
    sysctl -p /etc/sysctl.d/99-oracle.conf
    
    log "Параметры ядра настроены"
}

# Настройка лимитов системы
configure_limits() {
    log "Настройка лимитов системы..."
    
    # Добавление лимитов для oracle
    cat >> /etc/security/limits.conf << EOF

# Oracle Database 11g Limits
$ORACLE_USER soft nproc 2047
$ORACLE_USER hard nproc 16384
$ORACLE_USER soft nofile 1024
$ORACLE_USER hard nofile 65536
$ORACLE_USER soft stack 10240
EOF

    log "Лимиты системы настроены"
}

# Создание директорий Oracle
create_oracle_directories() {
    log "Создание директорий Oracle..."
    
    # Создание основных директорий
    mkdir -p "$ORACLE_BASE"
    mkdir -p "$ORACLE_HOME"
    mkdir -p "$ORACLE_INVENTORY"
    mkdir -p /opt/oracle/admin
    mkdir -p /opt/oracle/flash_recovery_area
    mkdir -p /opt/oracle/oradata
    
    # Установка прав
    chown -R "$ORACLE_USER:$ORACLE_GROUP" "$ORACLE_BASE"
    chown -R "$ORACLE_USER:$ORACLE_GROUP" "$ORACLE_INVENTORY"
    chmod -R 755 "$ORACLE_BASE"
    chmod -R 755 "$ORACLE_INVENTORY"
    
    log "Директории Oracle созданы"
}

# Настройка переменных окружения
configure_environment() {
    log "Настройка переменных окружения..."
    
    # Создание .bashrc для oracle
    cat > /home/$ORACLE_USER/.bashrc << EOF
# Oracle Database 11g Environment
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export ORACLE_UNQNAME=$ORACLE_DB_NAME
export PATH=\$ORACLE_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH
export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
export TNS_ADMIN=\$ORACLE_HOME/network/admin
export NLS_LANG=RUSSIAN_RUSSIA.AL32UTF8
EOF

    chown "$ORACLE_USER:$ORACLE_GROUP" /home/$ORACLE_USER/.bashrc
    
    log "Переменные окружения настроены"
}

# Создание ответного файла для установки
create_response_file() {
    log "Создание ответного файла для установки..."
    
    cat > /tmp/oracle_install.rsp << EOF
####################################################################
## Copyright(c) Oracle Corporation 1998,2011. All rights reserved.##
##                                                                ##
## Specify values for the variables listed below to customize     ##
## your installation.                                             ##
##                                                                ##
## Each variable is associated with a comment. The comment       ##
## can help to populate the variables with the appropriate       ##
## values.                                                        ##
##                                                                ##
## IMPORTANT NOTE: This file contains plain text passwords and    ##
## should be secured to have read permission only by oracle user ##
## or db administrator who owns this installation.               ##
##                                                                ##
####################################################################

#------------------------------------------------------------------------------
# Do not change the following system generated value. 
#------------------------------------------------------------------------------
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0

#------------------------------------------------------------------------------
# Specify the installation option.
# It can be one of the following:
# 1. INSTALL_DB_SWONLY
# 2. INSTALL_DB_AND_CONFIG
# 3. UPGRADE_DB
#------------------------------------------------------------------------------
oracle.install.option=INSTALL_DB_SWONLY

#------------------------------------------------------------------------------
# Specify the hostname of the system as set during the installation. The
# resulting hostname should be a fully qualified name.
#------------------------------------------------------------------------------
ORACLE_HOSTNAME=$(hostname)

#------------------------------------------------------------------------------
# Specify the Unix group to be set for the inventory directory.  
#------------------------------------------------------------------------------
UNIX_GROUP_NAME=$ORACLE_GROUP

#------------------------------------------------------------------------------
# Specify the location which holds the inventory files.
# This is an optional parameter if installing on
# Windows based Operating System.
#------------------------------------------------------------------------------
INVENTORY_LOCATION=$ORACLE_INVENTORY

#------------------------------------------------------------------------------
# Specify the languages in which the components will be installed.
#
# en   : English                    ja   : Japanese
# fr   : French                     ko   : Korean
# ar   : Arabic                     es   : Latin American Spanish
# bn   : Bengali                    lv   : Latvian
# pt_BR: Brazilian Portuguese      lt   : Lithuanian
# bg   : Bulgarian                  ms   : Malay
# fr_CA: Canadian French            es_MX: Mexican Spanish
# ca   : Catalan                    no   : Norwegian
# hr   : Croatian                   pl   : Polish
# cs   : Czech                      pt   : Portuguese
# da   : Danish                     ro   : Romanian
# nl   : Dutch                      ru   : Russian
# ar_EG: Egyptian Arabic            sk   : Slovak
# en_GB: English (Great Britain)    sl   : Slovenian
# et   : Estonian                   es_ES: Spanish
# fi   : Finnish                    sv   : Swedish
# de   : German                     th   : Thai
# el   : Greek                      tr   : Turkish
# iw   : Hebrew                     uk   : Ukrainian
# hu   : Hungarian                  vi   : Vietnamese
# is   : Icelandic                  zh_CN: Simplified Chinese
# in   : Indonesian                 zh_TW: Traditional Chinese
# it   : Italian
#
# all_languages   : All languages
#
# Specify value as the following to select any of the languages.
# Example : SELECTED_LANGUAGES=en,fr,ja
#
# Specify value as the following to select all the languages.
# Example : SELECTED_LANGUAGES=all_languages
#------------------------------------------------------------------------------
SELECTED_LANGUAGES=en,ru

#------------------------------------------------------------------------------
# Specify the complete path of the Oracle Home.
#------------------------------------------------------------------------------
ORACLE_HOME=$ORACLE_HOME

#------------------------------------------------------------------------------
# Specify the complete path of the Oracle Base.
#------------------------------------------------------------------------------
ORACLE_BASE=$ORACLE_BASE

#------------------------------------------------------------------------------
# Specify the installation edition of the component.
#
# The value should contain only one of the following choices.
# 1. EE     : Enterprise Edition
# 2. SE     : Standard Edition 
# 3. SEONE  : Standard Edition One
# 4. PE     : Personal Edition (WINDOWS ONLY)
#------------------------------------------------------------------------------
oracle.install.db.InstallEdition=EE

#------------------------------------------------------------------------------
# This variable is used to enable or disable the user to set the password for
# sys account during the installation.
#
# The value can be either true or false.
# If this value is set to false, you must set the password for
# sys account either manually or using Oracle Enterprise Manager.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.ALL=Oracle123!

#------------------------------------------------------------------------------
# Specify the My Oracle Support Account Username.
#
#  Example   : MYORACLESUPPORT_USERNAME=abc@xyz.com
#------------------------------------------------------------------------------
MYORACLESUPPORT_USERNAME=

#------------------------------------------------------------------------------
# Specify the My Oracle Support Account Username password.
#
# Example    : MYORACLESUPPORT_PASSWORD=password
#------------------------------------------------------------------------------
MYORACLESUPPORT_PASSWORD=

#------------------------------------------------------------------------------
# Specify whether to enable the user to set the password for My Oracle Support
# account. The value can be either true or false.
#
# If this value is set to false, you must set the password for
# My Oracle Support account either manually or using Oracle Enterprise Manager.
#------------------------------------------------------------------------------
MYORACLESUPPORT_PASSWORD_HIDDEN=false

#------------------------------------------------------------------------------
# Specify the Proxy server name. Port should be provided as well.
#
# Example    : SECURITY_UPDATES_VIA_MYORACLESUPPORT=true (true/false)
#------------------------------------------------------------------------------
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false

#------------------------------------------------------------------------------
# Specify whether user wants to give any proxy details or not.
# The value can be either true or false.
#
#  Example   : PROXY_HOST=proxy.domain.com
#              PROXY_PORT=25
#              PROXY_USER=username
#              PROXY_PWD=password
#              PROXY_REALM=realms
#              SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
#------------------------------------------------------------------------------
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=

#------------------------------------------------------------------------------
# Specify the cluster node names selected during the installation.
#
# Example : CLUSTER_NODES=node1,node2
#------------------------------------------------------------------------------
CLUSTER_NODES=

#------------------------------------------------------------------------------
# Specify the type of database to create.
# It can be one of the following:
# 1. GENERAL_PURPOSE
# 2. TRANSACTION_PROCESSING
# 3. DATA_WAREHOUSE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE

#------------------------------------------------------------------------------
# Specify the Starter Database Global Database Name.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.globalDBName=$ORACLE_DB_NAME

#------------------------------------------------------------------------------
# Specify the Starter Database SID.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.SID=$ORACLE_SID

#------------------------------------------------------------------------------
# Specify the Starter Database character set.
#
#  One of the following
# 1. AL32UTF8
# 2. UTF8
# 3. WE8MSWIN1252
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.characterSet=AL32UTF8

#------------------------------------------------------------------------------
# This variable should be set to true if Automatic Memory Management is not desired
# and you would like to configure the memory manually.
#
# The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.memoryOption=false

#------------------------------------------------------------------------------
# Specify the total memory allocation for the database. Value(in MB) should be
# at least 256 MB, and should not exceed the total physical memory available
# on the system.
# Example : oracle.install.db.config.starterdb.memoryLimit=512
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.memoryLimit=1024

#------------------------------------------------------------------------------
# This variable controls whether to load Example Schemas onto
# the starter database or not.
#
# The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.installExampleSchemas=false

#------------------------------------------------------------------------------
# This variable includes enabling audit settings, configuring password profiles
# and other security related settings as part of database installation.
#
# The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.enableSecuritySettings=true

#------------------------------------------------------------------------------
# Specify the password to be used for database schemas.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.SYS=$ORACLE_SYS_PASSWORD
oracle.install.db.config.starterdb.password.SYSTEM=$ORACLE_SYSTEM_PASSWORD
oracle.install.db.config.starterdb.password.SYSMAN=$ORACLE_SYSMAN_PASSWORD
oracle.install.db.config.starterdb.password.DBSNMP=$ORACLE_DBSNMP_PASSWORD

#------------------------------------------------------------------------------
# Specify the management option to use for this Oracle installation.
#
# The value can be one of the following:
# 1. GRID_CONTROL
# 2. DB_CONTROL
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.control=DB_CONTROL

#------------------------------------------------------------------------------
# Specify the Management Service to use if Grid Control is selected to manage
# the database.
#
# Example : oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=https://10.10.10.10:1158/em
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=

#------------------------------------------------------------------------------
# This variable indicates whether to configure the Database to use
# Enterprise Manager. The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.enableRecovery=true

#------------------------------------------------------------------------------
# Specify the Starter Database storage type.
#
# The value can be one of the following:
# 1. FILE_SYSTEM_STORAGE
# 2. ASM_STORAGE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE

#------------------------------------------------------------------------------
# Specify the database file location which is a directory for datafiles,
# control files, redo log files.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/opt/oracle/oradata

#------------------------------------------------------------------------------
# Specify the backup and recovery location.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=/opt/oracle/flash_recovery_area

#------------------------------------------------------------------------------
# Specify the existing ASM disk groups to be used for storage.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=ASM_STORAGE
# Example : oracle.install.db.config.starterdb.asm.diskGroup=/opt/oracle/oradata
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.asm.diskGroup=

#------------------------------------------------------------------------------
# Specify the ASM instance to be used for this database.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=ASM_STORAGE
# Example : oracle.install.db.config.starterdb.asm.ASMSNMPPassword=Oracle123!
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.asm.ASMSNMPPassword=

#------------------------------------------------------------------------------
# Specify the My Oracle Support Account Username.
# If you wish to ignore Oracle Configuration Manager configuration provide
# the value "dont_configure_ocm"
#
#  Example   : MYORACLESUPPORT_USERNAME=abc@xyz.com
#------------------------------------------------------------------------------
MYORACLESUPPORT_USERNAME=dont_configure_ocm

#------------------------------------------------------------------------------
# Specify the My Oracle Support Account Username password.
# If you wish to ignore Oracle Configuration Manager configuration provide
# the value "dont_configure_ocm"
#
# Example    : MYORACLESUPPORT_PASSWORD=password
#------------------------------------------------------------------------------
MYORACLESUPPORT_PASSWORD=dont_configure_ocm

#------------------------------------------------------------------------------
# Specify whether to enable the user to set the password for My Oracle Support
# account. The value can be either true or false.
#
# If this value is set to false, you must set the password for
# My Oracle Support account either manually or using Oracle Enterprise Manager.
#------------------------------------------------------------------------------
MYORACLESUPPORT_PASSWORD_HIDDEN=false

#------------------------------------------------------------------------------
# Specify the Proxy server name. Port should be provided as well.
#
# Example    : SECURITY_UPDATES_VIA_MYORACLESUPPORT=true (true/false)
#------------------------------------------------------------------------------
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false

#------------------------------------------------------------------------------
# Specify whether user wants to give any proxy details or not.
# The value can be either true or false.
#
#  Example   : PROXY_HOST=proxy.domain.com
#              PROXY_PORT=25
#              PROXY_USER=username
#              PROXY_PWD=password
#              PROXY_REALM=realms
#              SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
#------------------------------------------------------------------------------
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=

#------------------------------------------------------------------------------
# Specify the cluster node names selected during the installation.
#
# Example : CLUSTER_NODES=node1,node2
#------------------------------------------------------------------------------
CLUSTER_NODES=

#------------------------------------------------------------------------------
# Specify the type of database to create.
# It can be one of the following:
# 1. GENERAL_PURPOSE
# 2. TRANSACTION_PROCESSING
# 3. DATA_WAREHOUSE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE

#------------------------------------------------------------------------------
# Specify the Starter Database Global Database Name.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.globalDBName=$ORACLE_DB_NAME

#------------------------------------------------------------------------------
# Specify the Starter Database SID.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.SID=$ORACLE_SID

#------------------------------------------------------------------------------
# Specify the Starter Database character set.
#
#  One of the following
# 1. AL32UTF8
# 2. UTF8
# 3. WE8MSWIN1252
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.characterSet=AL32UTF8

#------------------------------------------------------------------------------
# This variable should be set to true if Automatic Memory Management is not desired
# and you would like to configure the memory manually.
#
# The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.memoryOption=false

#------------------------------------------------------------------------------
# Specify the total memory allocation for the database. Value(in MB) should be
# at least 256 MB, and should not exceed the total physical memory available
# on the system.
# Example : oracle.install.db.config.starterdb.memoryLimit=512
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.memoryLimit=1024

#------------------------------------------------------------------------------
# This variable controls whether to load Example Schemas onto
# the starter database or not.
#
# The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.installExampleSchemas=false

#------------------------------------------------------------------------------
# This variable includes enabling audit settings, configuring password profiles
# and other security related settings as part of database installation.
#
# The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.enableSecuritySettings=true

#------------------------------------------------------------------------------
# Specify the password to be used for database schemas.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.password.SYS=$ORACLE_SYS_PASSWORD
oracle.install.db.config.starterdb.password.SYSTEM=$ORACLE_SYSTEM_PASSWORD
oracle.install.db.config.starterdb.password.SYSMAN=$ORACLE_SYSMAN_PASSWORD
oracle.install.db.config.starterdb.password.DBSNMP=$ORACLE_DBSNMP_PASSWORD

#------------------------------------------------------------------------------
# Specify the management option to use for this Oracle installation.
#
# The value can be one of the following:
# 1. GRID_CONTROL
# 2. DB_CONTROL
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.control=DB_CONTROL

#------------------------------------------------------------------------------
# Specify the Management Service to use if Grid Control is selected to manage
# the database.
#
# Example : oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=https://10.10.10.10:1158/em
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=

#------------------------------------------------------------------------------
# This variable indicates whether to configure the Database to use
# Enterprise Manager. The value can be either true or false.
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.enableRecovery=true

#------------------------------------------------------------------------------
# Specify the Starter Database storage type.
#
# The value can be one of the following:
# 1. FILE_SYSTEM_STORAGE
# 2. ASM_STORAGE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE

#------------------------------------------------------------------------------
# Specify the database file location which is a directory for datafiles,
# control files, redo log files.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/opt/oracle/oradata

#------------------------------------------------------------------------------
# Specify the backup and recovery location.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=/opt/oracle/flash_recovery_area

#------------------------------------------------------------------------------
# Specify the existing ASM disk groups to be used for storage.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=ASM_STORAGE
# Example : oracle.install.db.config.starterdb.asm.diskGroup=/opt/oracle/oradata
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.asm.diskGroup=

#------------------------------------------------------------------------------
# Specify the ASM instance to be used for this database.
#
# Applicable only when oracle.install.db.config.starterdb.storageType=ASM_STORAGE
# Example : oracle.install.db.config.starterdb.asm.ASMSNMPPassword=Oracle123!
#------------------------------------------------------------------------------
oracle.install.db.config.starterdb.asm.ASMSNMPPassword=
EOF

    chown "$ORACLE_USER:$ORACLE_GROUP" /tmp/oracle_install.rsp
    
    log "Ответный файл создан: /tmp/oracle_install.rsp"
}


# Основная функция
main() {
    log "Начинаем установку Oracle Database $ORACLE_VERSION..."
    
    
    # Проверки
    check_root
    check_system
    
    # Настройка конфигурации Oracle
    setup_oracle_config
    
    # Подготовка системы
    create_oracle_users
    install_prerequisites
    configure_kernel
    configure_limits
    create_oracle_directories
    configure_environment
    create_response_file
    
    log "Подготовка системы завершена!"
    log "Конфигурация Oracle:"
    log_info "SID: $ORACLE_SID"
    log_info "Название БД: $ORACLE_DB_NAME"
    log_info "Пользователь: $ORACLE_USER"
    log_info "База: $ORACLE_BASE"
    log_info "Дом: $ORACLE_HOME"
    
    log "Следующие шаги:"
    log "1. Скачайте Oracle Database 11.2.0.4.0 с официального сайта"
    log "2. Распакуйте архив в /tmp/database/"
    log "3. Запустите установку от имени пользователя oracle:"
    log "   su - oracle"
    log "   cd /tmp/database"
    log "   ./runInstaller -silent -responseFile /tmp/oracle_install.rsp"
    log "4. После установки запустите root.sh:"
    log "   sudo $ORACLE_HOME/root.sh"
    
    log "Установка Oracle Database $ORACLE_VERSION подготовлена!"
}

# Запуск основной функции
main "$@"
