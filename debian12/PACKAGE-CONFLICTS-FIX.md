# 🔧 Исправление конфликтов пакетов

## Проблема

При установке пакетов могут возникнуть конфликты зависимостей:

- **NTP конфликт**: `ntp` конфликтует с `ntpsec`
- **UFW конфликт**: `ufw` конфликтует с `iptables-persistent` и `netfilter-persistent`

## 🚀 Быстрое исправление

### Для уже запущенного скрипта

Если скрипт уже запущен и показывает ошибки пакетов, выполните в другом терминале:

```bash
# Скачивание скрипта исправления
curl -fsSL https://raw.githubusercontent.com/ViktorTimofeev/devops-src/main/debian12/fix-package-conflicts.sh -o fix-conflicts.sh

# Предоставление прав на выполнение
chmod +x fix-conflicts.sh

# Запуск исправления
sudo ./fix-conflicts.sh
```

### Ручное исправление

```bash
# Обновление списка пакетов
sudo apt update

# Удаление проблемных пакетов
sudo apt remove -y ntp
sudo apt remove -y iptables-persistent

# Исправление сломанных пакетов
sudo apt --fix-broken install

# Очистка зависимостей
sudo apt autoremove -y
sudo apt autoclean

# Установка недостающих пакетов
sudo apt install -y systemd-timesyncd ufw fail2ban
```

## 🔧 Настройка systemd-timesyncd

После исправления конфликтов настройте синхронизацию времени:

```bash
# Создание конфигурации
sudo tee /etc/systemd/timesyncd.conf > /dev/null << 'EOF'
[Time]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
FallbackNTP=time.google.com time.cloudflare.com
PollIntervalMinSec=32
PollIntervalMaxSec=2048
RootDistanceMaxSec=5
EOF

# Включение службы
sudo systemctl enable systemd-timesyncd
sudo systemctl start systemd-timesyncd

# Синхронизация времени
sudo timedatectl set-ntp true

# Проверка статуса
timedatectl status
```

## 🛠️ Настройка UFW

После исправления конфликтов настройте файрвол:

```bash
# Сброс правил UFW
sudo ufw --force reset

# Политики по умолчанию
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Разрешенные порты
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Включение файрвола
sudo ufw --force enable

# Проверка статуса
sudo ufw status verbose
```

## 🔍 Проверка исправления

После применения исправлений проверьте:

```bash
# Проверка установленных пакетов
dpkg -l | grep -E "(ufw|fail2ban|systemd-timesyncd|openssh-server)"

# Проверка статуса служб
systemctl status ufw fail2ban systemd-timesyncd ssh

# Проверка синхронизации времени
timedatectl status

# Проверка файрвола
ufw status verbose
```

## 📋 Список исправленных пакетов

### Удаленные проблемные пакеты:
- `ntp` - заменен на `systemd-timesyncd`
- `iptables-persistent` - конфликтует с `ufw`

### Установленные пакеты:
- `systemd-timesyncd` - современная синхронизация времени
- `ufw` - файрвол
- `fail2ban` - защита от брутфорса
- `openssh-server` - SSH сервер
- `auditd` - аудит системы
- `apparmor` - принудительный контроль доступа

## 🆘 Если проблемы остаются

### Дополнительные действия:

1. **Полная очистка пакетов**:
   ```bash
   sudo apt clean
   sudo apt autoclean
   sudo apt autoremove -y
   sudo dpkg --configure -a
   ```

2. **Проверка источников пакетов**:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

3. **Перезагрузка системы**:
   ```bash
   sudo reboot
   ```

### Альтернативные решения:

1. **Использование только UFW** (без iptables-persistent):
   ```bash
   sudo apt install -y ufw
   sudo ufw enable
   ```

2. **Использование только systemd-timesyncd** (без ntp):
   ```bash
   sudo apt install -y systemd-timesyncd
   sudo systemctl enable systemd-timesyncd
   ```

## 📞 Поддержка

Если проблемы не решаются:

1. Проверьте версию Debian: `cat /etc/debian_version`
2. Убедитесь, что используете последнюю версию скрипта
3. Создайте issue в репозитории с описанием ошибок

---

**Примечание**: Исправления конфликтов включены в версию 1.1+ скрипта. При использовании обновленной версии проблемы должны решаться автоматически.
