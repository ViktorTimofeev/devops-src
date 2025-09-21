# 🗄️ Oracle Database 11.2.0.4.0 Installation

[![Oracle](https://img.shields.io/badge/Oracle-11.2.0.4.0-red.svg)](https://www.oracle.com/database/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Debian](https://img.shields.io/badge/Debian-12-blue.svg)](https://www.debian.org/)

> **Автоматическая установка Oracle Database 11.2.0.4.0 на Debian/Ubuntu**

## 🚀 Быстрый старт

### Предварительные требования

- **ОС**: Debian 12/11 или Ubuntu 20.04/22.04
- **Архитектура**: x86_64
- **Память**: Минимум 2GB RAM
- **Диск**: Минимум 10GB свободного места
- **Права**: root
- **Интернет**: curl или wget (автоматически устанавливается при необходимости)

### Установка

#### Интерактивная установка
```bash
# Скачивание и запуск скрипта (интерактивный режим)
curl -fsSL https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-11g-install.sh | bash

# Или локальная установка
sudo ./oracle-11g-install.sh
```

#### Неинтерактивная установка с параметрами через URL
```bash
# Установка с параметрами через URL (curl)
curl -fsSL "https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-with-params.sh?sid=prod&db_name=PROD&sys_password=MySecurePass123!" | bash

# Установка с параметрами через URL (wget)
wget -qO- "https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-with-wget.sh?sid=prod&db_name=PROD&sys_password=MySecurePass123!" | bash
```

#### Неинтерактивная установка с переменными окружения
```bash
# Установка с предустановленными параметрами (только для локального запуска)
ORACLE_SID_ENV=prod \
ORACLE_DB_NAME_ENV=PROD \
ORACLE_SYS_PASSWORD_ENV=MySecurePass123! \
ORACLE_SYSTEM_PASSWORD_ENV=MySecurePass123! \
ORACLE_SYSMAN_PASSWORD_ENV=MySecurePass123! \
ORACLE_DBSNMP_PASSWORD_ENV=MySecurePass123! \
./oracle-11g-install.sh
```

#### Неинтерактивная установка с паролями по умолчанию
```bash
# Установка с паролями по умолчанию (Oracle123!) - curl
curl -fsSL https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-11g-install.sh | bash

# Установка с паролями по умолчанию (Oracle123!) - wget
wget -qO- https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-wget.sh | bash
```

## 🔧 Альтернативные способы установки

### curl vs wget

| Способ | Команда | Описание |
|--------|---------|----------|
| **curl** | `curl -fsSL URL \| bash` | Стандартный способ, быстрый |
| **wget** | `wget -qO- URL \| bash` | Альтернатива для систем без curl |

### Автоматическая установка утилит

Скрипты автоматически проверяют и устанавливают необходимые утилиты:

```bash
# Проверка curl
if ! command -v curl >/dev/null 2>&1; then
    apt update -y && apt install -y curl
fi

# Проверка wget
if ! command -v wget >/dev/null 2>&1; then
    apt update -y && apt install -y wget
fi
```

### Рекомендации по выбору

- **curl**: Рекомендуется для современных систем
- **wget**: Используйте если curl недоступен или заблокирован
- **Локальная установка**: Для систем без интернета

## 📋 Что делает скрипт

### 1. Проверка системы
- Проверка ОС (Debian/Ubuntu)
- Проверка архитектуры (x86_64)
- Проверка памяти (минимум 2GB)

### 2. Создание пользователей и групп
- Группы: `oinstall`, `dba`, `oper`
- Пользователь: `oracle`
- Настройка прав доступа

### 3. Установка пакетов
- Необходимые библиотеки и утилиты
- Пакеты для компиляции
- Системные утилиты

### 4. Настройка ядра
- Параметры shared memory
- Настройки сети
- Оптимизация производительности

### 5. Настройка системы
- Лимиты для пользователя oracle
- Переменные окружения
- Директории Oracle

### 6. Создание ответного файла
- Автоматическая конфигурация установки
- Настройки базы данных
- Пароли и параметры

## 🔧 Конфигурация

### Переменные Oracle

```bash
ORACLE_VERSION="11.2.0.4.0"
ORACLE_BASE="/opt/oracle"
ORACLE_HOME="/opt/oracle/product/11.2.0/dbhome_1"
ORACLE_SID=""  # Задается пользователем при установке
ORACLE_DB_NAME=""  # Задается пользователем при установке
ORACLE_USER="oracle"
ORACLE_GROUP="oinstall"
```

### URL параметры (рекомендуемый способ)

Для неинтерактивной установки через `curl | bash` используйте URL параметры:

| Параметр | Описание | Пример |
|----------|----------|---------|
| `sid` | Oracle SID | `prod`, `dev`, `test` |
| `db_name` | Название базы данных | `PROD`, `DEV`, `TEST` |
| `sys_password` | Пароль для пользователя SYS | `MySecurePass123!` |
| `system_password` | Пароль для пользователя SYSTEM | `MySecurePass123!` |
| `sysman_password` | Пароль для пользователя SYSMAN | `MySecurePass123!` |
| `dbsnmp_password` | Пароль для пользователя DBSNMP | `MySecurePass123!` |

**Примеры URL:**
```
# curl
https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-with-params.sh?sid=prod&db_name=PROD&sys_password=MySecurePass123!

# wget
https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/oracle/oracle-install-with-wget.sh?sid=prod&db_name=PROD&sys_password=MySecurePass123!
```

### Переменные окружения

Для локальной установки можно использовать переменные окружения:

| Переменная | Описание | Пример |
|------------|----------|---------|
| `ORACLE_SID_ENV` | Oracle SID | `prod`, `dev`, `test` |
| `ORACLE_DB_NAME_ENV` | Название базы данных | `PROD`, `DEV`, `TEST` |
| `ORACLE_SYS_PASSWORD_ENV` | Пароль для пользователя SYS | `MySecurePass123!` |
| `ORACLE_SYSTEM_PASSWORD_ENV` | Пароль для пользователя SYSTEM | `MySecurePass123!` |
| `ORACLE_SYSMAN_PASSWORD_ENV` | Пароль для пользователя SYSMAN | `MySecurePass123!` |
| `ORACLE_DBSNMP_PASSWORD_ENV` | Пароль для пользователя DBSNMP | `MySecurePass123!` |

### Интерактивная настройка

При установке Oracle скрипт запросит у пользователя (если переменные окружения не заданы):

1. **Oracle SID** (например: orcl, prod, dev)
   - Длина: 1-8 символов
   - Разрешены: буквы, цифры, дефис, подчеркивание
   - Проверка на зарезервированные имена

2. **Название базы данных** (например: PROD, DEV, TEST)
   - Длина: 1-30 символов
   - Разрешены: буквы, цифры, дефис, подчеркивание

3. **Пароли для пользователей Oracle**:
   - **SYS** - системный пользователь
   - **SYSTEM** - административный пользователь
   - **SYSMAN** - пользователь Enterprise Manager
   - **DBSNMP** - пользователь мониторинга

#### Требования к паролям:
- Минимум 8 символов
- Минимум 3 из 4 типов символов:
  - Заглавные буквы (A-Z)
  - Строчные буквы (a-z)
  - Цифры (0-9)
  - Специальные символы (!@#$%^&*)
- Подтверждение пароля

## 📁 Структура установки

```
/opt/oracle/
├── product/11.2.0/dbhome_1/    # Oracle Home
├── admin/                       # Административные файлы
├── flash_recovery_area/         # Recovery Area
└── oradata/                     # Данные базы

/opt/oraInventory/               # Oracle Inventory
```

## 🛠️ Ручная установка

### 1. Подготовка системы
```bash
sudo ./oracle-11g-install.sh
```

### 2. Скачивание Oracle
1. Перейдите на [Oracle Technology Network](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html)
2. Скачайте Oracle Database 11.2.0.4.0 для Linux x86-64
3. Распакуйте архив в `/tmp/database/`

### 3. Запуск установки
```bash
# Переключение на пользователя oracle
su - oracle

# Переход в директорию установки
cd /tmp/database

# Запуск установщика
./runInstaller -silent -responseFile /tmp/oracle_install.rsp
```

### 4. Завершение установки
```bash
# Запуск root.sh (от root)
sudo /opt/oracle/product/11.2.0/dbhome_1/root.sh
```

## 🔍 Проверка установки

### Проверка служб
```bash
# Проверка процессов Oracle
ps aux | grep oracle

# Проверка портов
netstat -tlnp | grep 1521
```

### Подключение к базе
```bash
# Переключение на oracle
su - oracle

# Подключение к SQL*Plus
sqlplus / as sysdba

# Проверка статуса
SQL> SELECT status FROM v$instance;
SQL> EXIT;
```

### Проверка Enterprise Manager
- URL: `http://localhost:1158/em`
- Пользователь: `sys`
- Пароль: `Oracle123!`

## 🛡️ Безопасность

### Обязательные действия после установки

1. **Измените пароли**:
   ```sql
   ALTER USER sys IDENTIFIED BY "NewPassword123!";
   ALTER USER system IDENTIFIED BY "NewPassword123!";
   ```

2. **Настройте файрвол**:
   ```bash
   sudo ufw allow 1521/tcp comment 'Oracle Database'
   sudo ufw allow 1158/tcp comment 'Oracle EM'
   ```

3. **Настройте резервное копирование**:
   ```bash
   # Создание скрипта бэкапа
   cat > /opt/oracle/backup.sh << 'EOF'
   #!/bin/bash
   export ORACLE_HOME=/opt/oracle/product/11.2.0/dbhome_1
   export ORACLE_SID=orcl
   $ORACLE_HOME/bin/rman target / << EOF_RMAN
   BACKUP DATABASE PLUS ARCHIVELOG;
   EXIT;
   EOF_RMAN
   EOF
   ```

## 📊 Мониторинг

### Проверка использования ресурсов
```bash
# Использование памяти Oracle
free -h

# Использование диска
df -h /opt/oracle

# Процессы Oracle
ps aux | grep oracle | wc -l
```

### Логи Oracle
```bash
# Alert log
tail -f /opt/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log

# Listener log
tail -f /opt/oracle/diag/tnslsnr/$(hostname)/listener/trace/listener.log
```

## 🚨 Устранение неполадок

### Частые проблемы

#### 1. Ошибка "ORA-12541: TNS:no listener"
```bash
# Запуск listener
su - oracle
lsnrctl start
```

#### 2. Ошибка "ORA-01034: ORACLE not available"
```bash
# Запуск базы данных
su - oracle
sqlplus / as sysdba
SQL> STARTUP;
SQL> EXIT;
```

#### 3. Проблемы с памятью
```bash
# Проверка параметров ядра
sysctl kernel.shmmax
sysctl kernel.shmall

# Увеличение лимитов
echo "oracle soft memlock unlimited" >> /etc/security/limits.conf
echo "oracle hard memlock unlimited" >> /etc/security/limits.conf
```

### Логи для диагностики
- **Alert Log**: `/opt/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log`
- **Install Log**: `/opt/oraInventory/logs/installActions*.log`
- **Listener Log**: `/opt/oracle/diag/tnslsnr/$(hostname)/listener/trace/listener.log`

## 📚 Дополнительные ресурсы

### Документация Oracle
- [Oracle Database 11g Documentation](https://docs.oracle.com/cd/E11882_01/index.htm)
- [Oracle Database Installation Guide](https://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm)

### Полезные команды
```bash
# Проверка версии Oracle
sqlplus -v

# Проверка переменных окружения
env | grep ORACLE

# Проверка статуса listener
lsnrctl status

# Проверка статуса базы
sqlplus / as sysdba << 'EOF'
SELECT instance_name, status FROM v$instance;
EXIT;
EOF
```

## 🤝 Поддержка

При возникновении проблем:
1. Проверьте логи Oracle
2. Убедитесь в корректности переменных окружения
3. Проверьте права доступа к файлам
4. Обратитесь к документации Oracle

---

**⚠️ Важно**: Этот скрипт предназначен для тестовых и разработческих сред. Для продакшн использования требуется дополнительная настройка безопасности и производительности.
