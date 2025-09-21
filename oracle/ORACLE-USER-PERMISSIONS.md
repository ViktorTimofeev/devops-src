# Права пользователя Oracle для установки

## 📋 Обзор

Для установки Oracle Database 11.2.0.4.0 пользователь `oracle` должен иметь определенные права и принадлежать к специальным группам. Скрипт автоматически настраивает все необходимые права.

## 👤 Пользователь Oracle

### Основные характеристики
- **Имя пользователя**: `oracle`
- **Основная группа**: `oinstall` (Oracle Install)
- **Дополнительные группы**: `dba`, `oper`
- **Домашняя директория**: `/home/oracle`
- **Оболочка**: `/bin/bash`

### Команда создания пользователя
```bash
useradd -g oinstall -G dba,oper -m -s /bin/bash oracle
```

## 🔐 Группы Oracle

### 1. **oinstall** (Oracle Install)
- **Назначение**: Основная группа для установки Oracle
- **Права**: Доступ к файлам установки и конфигурации
- **Использование**: Установка и обновление Oracle

### 2. **dba** (Database Administrator)
- **Назначение**: Административные права базы данных
- **Права**: Полный доступ к Oracle Database
- **Использование**: Управление базами данных, создание пользователей

### 3. **oper** (Operator)
- **Назначение**: Операционные права
- **Права**: Запуск/остановка сервисов, мониторинг
- **Использование**: Операционные задачи без административных прав

## 📁 Права доступа к директориям

### Основные директории Oracle
```bash
# ORACLE_BASE: /opt/oracle
# ORACLE_HOME: /opt/oracle/product/11.2.0/dbhome_1
# ORACLE_INVENTORY: /opt/oraInventory
```

### Права доступа
```bash
# Владелец: oracle:oinstall
# Права: 755 (rwxr-xr-x)
chown -R oracle:oinstall /opt/oracle
chown -R oracle:oinstall /opt/oraInventory
chmod -R 755 /opt/oracle
chmod -R 755 /opt/oraInventory
```

### Структура директорий
```
/opt/oracle/                    # ORACLE_BASE
├── product/                    # Продукты Oracle
│   └── 11.2.0/
│       └── dbhome_1/           # ORACLE_HOME
├── admin/                      # Административные файлы
├── cfgtoollogs/               # Логи конфигурации
├── diag/                      # Диагностические файлы
└── flash_recovery_area/       # Область восстановления

/opt/oraInventory/             # Инвентарь Oracle
├── ContentsXML/
├── logs/
└── oui/
```

## ⚙️ Системные лимиты

### Настройка в /etc/security/limits.conf
```bash
# Oracle Database 11g Limits
oracle soft nproc 2047          # Мягкий лимит процессов
oracle hard nproc 16384         # Жесткий лимит процессов
oracle soft nofile 1024         # Мягкий лимит открытых файлов
oracle hard nofile 65536        # Жесткий лимит открытых файлов
oracle soft stack 10240         # Размер стека (KB)
```

### Объяснение лимитов
- **nproc**: Количество процессов, которые может создать пользователь
- **nofile**: Количество файлов, которые может открыть пользователь
- **stack**: Размер стека для процессов пользователя

## 🔧 Переменные окружения

### Основные переменные Oracle
```bash
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=orcl
export ORACLE_UNQNAME=ORCL
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export TNS_ADMIN=$ORACLE_HOME/network/admin
export NLS_LANG=RUSSIAN_RUSSIA.AL32UTF8
```

### Файл конфигурации
- **Расположение**: `/home/oracle/.bashrc`
- **Владелец**: `oracle:oinstall`
- **Права**: `644`

## 🚀 Права для установки

### 1. **Права root для подготовки системы**
```bash
# Только root может:
- Создавать пользователей и группы
- Устанавливать системные пакеты
- Настраивать системные лимиты
- Создавать директории в /opt/
- Настраивать параметры ядра
```

### 2. **Права oracle для установки Oracle**
```bash
# Пользователь oracle может:
- Запускать runInstaller
- Устанавливать Oracle в ORACLE_HOME
- Создавать базы данных
- Настраивать сетевые параметры
```

### 3. **Права root для post-install**
```bash
# Только root может:
- Запускать root.sh
- Настраивать системные сервисы
- Устанавливать права на системные файлы
```

## 📋 Проверка прав

### Проверка пользователя
```bash
# Проверка существования пользователя
id oracle

# Проверка групп
groups oracle

# Проверка домашней директории
ls -la /home/oracle/
```

### Проверка групп
```bash
# Проверка групп Oracle
getent group oinstall
getent group dba
getent group oper
```

### Проверка директорий
```bash
# Проверка прав на директории
ls -la /opt/oracle/
ls -la /opt/oraInventory/

# Проверка владельца
stat /opt/oracle
stat /opt/oraInventory
```

### Проверка лимитов
```bash
# Проверка лимитов для oracle
ulimit -a

# Проверка конфигурации лимитов
grep oracle /etc/security/limits.conf
```

## 🔒 Безопасность

### Принципы безопасности
1. **Минимальные права**: Пользователь oracle имеет только необходимые права
2. **Разделение ролей**: Разные группы для разных функций
3. **Изоляция**: Oracle работает в изолированной среде
4. **Аудит**: Все действия логируются

### Рекомендации
- Не давайте пользователю oracle права root
- Регулярно проверяйте права доступа
- Используйте отдельные учетные записи для разных ролей
- Настройте мониторинг доступа к критическим файлам

## 🛠️ Устранение проблем

### Проблема: Пользователь oracle не может создать файлы
```bash
# Решение: Проверить права на директорию
ls -la /opt/oracle/
chown -R oracle:oinstall /opt/oracle/
chmod -R 755 /opt/oracle/
```

### Проблема: Превышены лимиты файлов
```bash
# Решение: Увеличить лимиты
echo "oracle soft nofile 65536" >> /etc/security/limits.conf
echo "oracle hard nofile 65536" >> /etc/security/limits.conf
```

### Проблема: Пользователь oracle не может запустить Oracle
```bash
# Решение: Проверить переменные окружения
su - oracle
env | grep ORACLE
```

## 📚 Дополнительная информация

### Связанные файлы
- `/etc/passwd` - Информация о пользователях
- `/etc/group` - Информация о группах
- `/etc/security/limits.conf` - Системные лимиты
- `/home/oracle/.bashrc` - Переменные окружения Oracle

### Полезные команды
```bash
# Переключение на пользователя oracle
su - oracle

# Проверка текущего пользователя
whoami

# Проверка групп текущего пользователя
groups

# Проверка переменных окружения Oracle
env | grep ORACLE
```

---

**Автор**: DevOps Expert Team  
**Версия**: 1.4  
**Дата**: 2025-09-21
