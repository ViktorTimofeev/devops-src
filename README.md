# 🛡️ DevOps Security Tools

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Debian](https://img.shields.io/badge/Debian-12-blue.svg)](https://www.debian.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

> **Коллекция инструментов DevOps для настройки и защиты серверов**

## 📁 Структура проекта

```
DevOps/
├── debian12/                          # Скрипты настройки Debian 12
│   ├── debian12-server-setup.sh       # Основной скрипт настройки
│   ├── security-check.sh              # Скрипт проверки безопасности
│   ├── install-from-github.sh          # Скрипт установки с GitHub
│   ├── config.env                      # Конфигурационный файл
│   ├── Makefile                        # Makefile для управления
│   ├── README.md                       # Документация Debian 12
│   ├── DEPLOYMENT.md                   # Руководство по развертыванию
│   ├── GITHUB-README.md               # README для GitHub
│   ├── FILES.md                       # Описание файлов
│   ├── PROJECT-SUMMARY.md             # Отчет о проекте
│   ├── CHANGELOG.md                   # История изменений
│   └── *.zip                          # Архивы релизов
├── .gitignore                          # Git ignore файл
└── README.md                          # Данный файл
```

## 🚀 Быстрый старт

### Debian 12 Server Setup

```bash
# Установка одной командой
curl -fsSL https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/debian12/install-from-github.sh | bash
```

### Локальная установка

```bash
# Клонирование репозитория
git clone https://github.com/ViktorTimofeev/devops-src.git
cd your-repo/debian12

# Запуск настройки
sudo ./debian12-server-setup.sh
```

## 🛡️ Возможности Debian 12 Setup

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
- **Интерактивная настройка** - Пользователь задает имя и пароль администратора
- **Auto Updates** - Автоматические обновления безопасности
- **Network Optimization** - Оптимизация сетевых параметров
- **Time Sync** - Синхронизация времени (NTP)
- **System Monitoring** - Мониторинг ресурсов
- **Backup System** - Автоматическое резервное копирование

### 📊 Мониторинг и логирование
- **Comprehensive Logging** - Детальное логирование всех событий
- **Resource Monitoring** - Мониторинг CPU, памяти, диска
- **Security Reports** - Автоматические отчеты о безопасности
- **Log Rotation** - Ротация и архивирование логов

## 🔧 Интерактивная настройка

При запуске скрипта вам будет предложено:

### 📝 Ввод имени пользователя
- ✅ Только буквы, цифры, дефис и подчеркивание
- ✅ Длина от 3 до 32 символов
- ✅ Не зарезервированные системой имена
- ✅ Уникальное имя (не существующий пользователь)

### 🔐 Ввод пароля
- ✅ Минимум 8 символов
- ✅ Минимум 3 из 4 типов символов:
  - 🔤 Заглавные буквы (A-Z)
  - 🔤 Строчные буквы (a-z)
  - 🔢 Цифры (0-9)
  - 🔣 Специальные символы (!@#$%^&*)
- ✅ Подтверждение пароля

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

## 🔍 Проверка безопасности

После установки запустите проверку:

```bash
# Проверка безопасности
security-check

# Или напрямую
sudo /usr/local/bin/security-check.sh
```

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

**⚠️ Важно**: Эти скрипты предназначены для использования на серверах Debian 12. Тестируйте изменения в безопасной среде перед применением на продакшн серверах.

**🔒 Безопасность**: Регулярно обновляйте систему и проверяйте логи безопасности.

**📚 Документация**: Подробная документация доступна в соответствующих папках проекта.
