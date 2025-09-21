# 🔧 Исправление проблемы с кодировкой UTF-8

## Проблема

Если при запуске скрипта русские символы отображаются как ромбики (♦), это означает проблему с кодировкой UTF-8.

## 🚀 Быстрое исправление

### Для уже запущенного скрипта

Если скрипт уже запущен и вы видите ромбики, выполните в другом терминале:

```bash
# Установка русской локали
sudo apt update
sudo apt install -y locales
sudo sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen

# Установка локали для текущей сессии
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8

# Перезапуск скрипта (если необходимо)
sudo ./debian12-server-setup.sh
```

### Для нового запуска

```bash
# Скачивание обновленного скрипта
curl -fsSL https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/debian12/debian12-server-setup.sh -o debian12-server-setup-fixed.sh

# Предоставление прав на выполнение
chmod +x debian12-server-setup-fixed.sh

# Запуск исправленного скрипта
sudo ./debian12-server-setup-fixed.sh
```

## 🔍 Проверка кодировки

### Проверка текущей локали
```bash
locale
```

### Проверка доступных локалей
```bash
locale -a | grep ru
```

### Проверка кодировки терминала
```bash
echo $LANG
echo $LC_ALL
```

## 🛠️ Настройка терминала

### Для SSH клиентов

#### PuTTY
1. Откройте настройки PuTTY
2. Перейдите в **Window** → **Translation**
3. Установите **Character set**: UTF-8
4. Переподключитесь к серверу

#### Windows Terminal / PowerShell
```powershell
# Установка UTF-8 для PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:LANG = "ru_RU.UTF-8"
```

#### Linux терминал
```bash
# Установка UTF-8 для текущей сессии
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8

# Постоянная настройка в ~/.bashrc
echo 'export LANG=ru_RU.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=ru_RU.UTF-8' >> ~/.bashrc
source ~/.bashrc
```

## 📋 Системные настройки

### Настройка локали системы

```bash
# Редактирование файла локали
sudo dpkg-reconfigure locales

# Или ручная настройка
sudo nano /etc/locale.conf
```

Добавьте:
```
LANG=ru_RU.UTF-8
LC_ALL=ru_RU.UTF-8
```

### Настройка часового пояса

```bash
# Установка часового пояса
sudo timedatectl set-timezone Europe/Moscow

# Проверка настроек
timedatectl status
```

## 🔄 Перезапуск сервисов

После изменения локали:

```bash
# Перезапуск системных сервисов
sudo systemctl restart systemd-logind
sudo systemctl restart ssh

# Перезагрузка системы (рекомендуется)
sudo reboot
```

## ✅ Проверка исправления

После применения исправлений проверьте:

```bash
# Проверка отображения русских символов
echo "Тест русских символов: Привет, мир!"

# Проверка локали
locale

# Проверка кодировки файлов
file -bi /etc/passwd
```

## 🆘 Если проблема остается

### Альтернативные решения

1. **Использование английской версии**:
   ```bash
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8
   ```

2. **Проверка шрифтов терминала**:
   - Убедитесь, что терминал поддерживает UTF-8
   - Установите шрифты с поддержкой кириллицы

3. **Проверка SSH конфигурации**:
   ```bash
   # В /etc/ssh/sshd_config
   AcceptEnv LANG LC_*
   ```

## 📞 Поддержка

Если проблема не решается:

1. Проверьте версию скрипта: `grep "Версия:" debian12-server-setup.sh`
2. Убедитесь, что используете последнюю версию с GitHub
3. Создайте issue в репозитории с описанием проблемы

---

**Примечание**: Исправления кодировки включены в версию 1.1+ скрипта. При использовании обновленной версии проблема должна решаться автоматически.
