# 🛡️ Debian 12 Server Setup & Security Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Debian](https://img.shields.io/badge/Debian-12-blue.svg)](https://www.debian.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

> **Комплексный скрипт для настройки и защиты сервера Debian 12 с максимальными мерами безопасности**

## 🚀 Быстрый старт

### Установка одной командой

```bash
curl -fsSL https://raw.githubusercontent.com/your-username/your-repo/main/debian12/install-from-github.sh | bash
```

### Или скачайте и запустите локально

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo/debian12
sudo ./debian12-server-setup.sh
```

## ✨ Возможности

### 🔒 Безопасность
- **SSH Hardening** - Отключение root, ограничение попыток входа
- **Firewall (UFW)** - Настройка правил и политик безопасности
- **Fail2ban** - Защита от брутфорс атак
- **Antivirus (ClamAV)** - Сканирование на вирусы
- **Rootkit Detection** - rkhunter, chkrootkit
- **File Integrity** - AIDE для мониторинга изменений
- **AppArmor** - Принудительный контроль доступа
- **Audit Logging** - auditd для отслеживания событий

### ⚙️ Системные настройки
- **Auto Updates** - Автоматические обновления безопасности
- **User Management** - Создание пользователя администратора
- **Network Optimization** - Оптимизация сетевых параметров
- **Time Sync** - Синхронизация времени (NTP)
- **System Monitoring** - Мониторинг ресурсов
- **Backup System** - Автоматическое резервное копирование

### 📊 Мониторинг и логирование
- **Comprehensive Logging** - Детальное логирование всех событий
- **Resource Monitoring** - Мониторинг CPU, памяти, диска
- **Security Reports** - Автоматические отчеты о безопасности
- **Log Rotation** - Ротация и архивирование логов

## 📋 Предварительные требования

- **OS**: Debian 12 (Bookworm) или новее
- **Architecture**: x86_64, ARM64
- **RAM**: Минимум 1GB
- **Disk**: Минимум 10GB свободного места
- **Network**: Подключение к интернету
- **Access**: Права root

## 🛠️ Установка

### Способ 1: GitHub (Рекомендуется)

```bash
# Быстрая установка
curl -fsSL https://raw.githubusercontent.com/your-username/your-repo/main/debian12/install-from-github.sh | bash
```

### Способ 2: Локальная установка

```bash
# Клонирование репозитория
git clone https://github.com/your-username/your-repo.git
cd your-repo/debian12

# Запуск установки
sudo ./debian12-server-setup.sh
```

### Способ 3: Использование Makefile

```bash
# Клонирование и установка
git clone https://github.com/your-username/your-repo.git
cd your-repo/debian12

# Установка зависимостей
make dev-deps

# Быстрая установка
make quick-install
```

## 🔧 Конфигурация

### Интерактивная настройка

При запуске скрипта вам будет предложено настроить пользователя администратора:

#### 📝 Ввод имени пользователя
- ✅ Только буквы, цифры, дефис и подчеркивание
- ✅ Длина от 3 до 32 символов
- ✅ Не зарезервированные системой имена
- ✅ Уникальное имя (не существующий пользователь)

#### 🔐 Ввод пароля
- ✅ Минимум 8 символов
- ✅ Минимум 3 из 4 типов символов:
  - 🔤 Заглавные буквы (A-Z)
  - 🔤 Строчные буквы (a-z)
  - 🔢 Цифры (0-9)
  - 🔣 Специальные символы (!@#$%^&*)
- ✅ Подтверждение пароля

#### 💡 Примеры валидных данных
```bash
# Имя пользователя
myadmin
server-admin
admin123
user_name

# Пароль (минимум 3 типа символов)
MySecure123!
AdminPass2024
Server#2024
```

### Дополнительные параметры

Отредактируйте файл `config.env` для других настроек:

```bash
# Настройки SSH
SSH_PORT="22"

# Настройки безопасности
FAIL2BAN_BANTIME="3600"
UFW_ALLOW_PORTS="22,80,443"

# Настройки мониторинга
MONITOR_DISK_THRESHOLD="80"
MONITOR_MEMORY_THRESHOLD="80"
```

### Настройка GitHub репозитория

Обновите переменные в скриптах:

```bash
# В install-from-github.sh
GITHUB_REPO="your-username/your-repo"
```

## 📖 Использование

### Основные команды

```bash
# Проверка безопасности
security-check

# Обновление скриптов
/usr/local/bin/update-security-scripts.sh

# Проверка статуса служб
systemctl status ssh ufw fail2ban auditd apparmor
```

### Makefile команды

```bash
make help          # Показать помощь
make install       # Установка с GitHub
make setup         # Локальная настройка
make security      # Проверка безопасности
make check         # Проверка скриптов
make test          # Тестирование
make validate      # Валидация конфигурации
```

## 🔍 Проверка безопасности

После установки запустите проверку:

```bash
# Проверка безопасности
security-check

# Или напрямую
sudo /usr/local/bin/security-check.sh
```

### Что проверяется:
- ✅ SSH конфигурация
- ✅ Файрвол UFW
- ✅ Fail2ban статус
- ✅ Пользователи и группы
- ✅ Сетевые настройки
- ✅ Открытые порты
- ✅ Логи безопасности
- ✅ Антивирус
- ✅ Rootkit сканеры

## 📊 Мониторинг

### Системные ресурсы
```bash
# Мониторинг в реальном времени
htop

# Использование диска
df -h

# Использование памяти
free -h

# Сетевые соединения
ss -tlnp
```

### Логи безопасности
```bash
# SSH логи
tail -f /var/log/auth.log

# Fail2ban логи
tail -f /var/log/fail2ban.log

# Системные логи
journalctl -f
```

## 🛡️ Безопасность

### Обязательные действия после установки

1. **Настройте SSH ключи для созданного пользователя**
   ```bash
   ssh-copy-id your-admin-user@your-server-ip
   ```

2. **Проверьте права пользователя**
   ```bash
   sudo -l
   ```

3. **Обновите базы антивируса**
   ```bash
   sudo freshclam
   ```

4. **Запустите проверку на rootkit**
   ```bash
   sudo rkhunter --check
   ```

### Регулярное обслуживание

```bash
# Еженедельные задачи
sudo apt update && sudo apt upgrade
sudo freshclam
sudo rkhunter --check

# Ежемесячные задачи
security-check
sudo aide --check
```

## 📁 Структура проекта

```
debian12/
├── debian12-server-setup.sh    # Основной скрипт настройки
├── security-check.sh           # Скрипт проверки безопасности
├── install-from-github.sh      # Скрипт установки с GitHub
├── config.env                   # Конфигурационный файл
├── Makefile                     # Makefile для управления
├── README.md                    # Основная документация
├── DEPLOYMENT.md               # Руководство по развертыванию
└── FILES.md                    # Описание файлов
```

## 🚨 Устранение неполадок

### Частые проблемы

#### SSH проблемы
```bash
# Проверка конфигурации
sudo sshd -t

# Перезапуск SSH
sudo systemctl restart ssh
```

#### Файрвол проблемы
```bash
# Сброс правил
sudo ufw --force reset

# Включение файрвола
sudo ufw enable
```

#### Fail2ban проблемы
```bash
# Проверка статуса
sudo fail2ban-client status

# Перезапуск
sudo systemctl restart fail2ban
```

### Логи и диагностика

```bash
# Основные лог-файлы
/var/log/debian12-setup.log      # Лог установки
/var/log/auth.log                # Логи аутентификации
/var/log/fail2ban.log           # Логи fail2ban
/var/log/system-monitor.log     # Логи мониторинга

# Отчеты
/root/setup-report-YYYY-MM-DD.txt      # Отчет установки
/root/security-report-YYYY-MM-DD.txt  # Отчет безопасности
```

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие проекта!

### Как помочь:
1. 🐛 **Сообщения об ошибках** - Создайте issue
2. 💡 **Предложения** - Предложите новые функции
3. 🔧 **Pull Requests** - Внесите изменения
4. 📖 **Документация** - Улучшите документацию

### Процесс разработки:
1. Fork репозитория
2. Создайте feature branch
3. Внесите изменения
4. Добавьте тесты
5. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для подробностей.

## 👥 Авторы

**DevOps Expert Team** - Команда экспертов по DevOps практикам с большим опытом построения сложных, отказоустойчивых и безопасных инфраструктурных проектов.

## 🙏 Благодарности

- Сообщество Debian за отличную операционную систему
- Разработчики инструментов безопасности
- Сообщество DevOps за лучшие практики

## 📞 Поддержка

- 📧 **Email**: [your-email@example.com]
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-username/your-repo/issues)
- 📖 **Документация**: [Wiki](https://github.com/your-username/your-repo/wiki)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-username/your-repo/discussions)

## ⭐ Звезды

Если этот проект помог вам, поставьте звезду! ⭐

---

**⚠️ Важно**: Этот скрипт предназначен для использования на серверах Debian 12. Тестируйте изменения в безопасной среде перед применением на продакшн серверах.

**🔒 Безопасность**: Регулярно обновляйте систему и проверяйте логи безопасности.

**📚 Документация**: Подробная документация доступна в файлах README.md и DEPLOYMENT.md.
