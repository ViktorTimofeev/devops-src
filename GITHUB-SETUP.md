# 🚀 Настройка GitHub репозитория

## 📋 Инструкции по размещению на GitHub

### 1. Создание репозитория на GitHub

1. Перейдите на [GitHub](https://github.com)
2. Нажмите кнопку **"New repository"**
3. Заполните форму:
   - **Repository name**: `devops-security-tools` (или ваше название)
   - **Description**: `DevOps Security Tools - Debian 12 Server Setup with Security Hardening`
   - **Visibility**: Public (рекомендуется)
   - **Initialize**: НЕ отмечайте (у нас уже есть файлы)

### 2. Подключение локального репозитория к GitHub

```bash
# Добавьте remote origin (замените YOUR_USERNAME и YOUR_REPO)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Установите основную ветку
git branch -M main

# Отправьте код на GitHub
git push -u origin main
```

### 3. Настройка репозитория

#### Обновление ссылок в файлах

После создания репозитория обновите следующие файлы:

**В `debian12/install-from-github.sh`:**
```bash
GITHUB_REPO="YOUR_USERNAME/YOUR_REPO"
```

**В `debian12/config.env`:**
```bash
GITHUB_REPO="YOUR_USERNAME/YOUR_REPO"
```

**В `README.md` и других документах:**
Замените все упоминания `your-username/your-repo` на ваши данные.

### 4. Настройка GitHub Pages (опционально)

Для создания документации:

1. Перейдите в **Settings** → **Pages**
2. Выберите источник: **Deploy from a branch**
3. Выберите ветку: **main**
4. Выберите папку: **/ (root)**
5. Сохраните настройки

### 5. Настройка GitHub Actions (опционально)

Создайте файл `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Test shell scripts
      run: |
        # Установка shellcheck
        sudo apt-get install shellcheck
        
        # Проверка скриптов
        shellcheck debian12/*.sh
        
        # Проверка синтаксиса
        bash -n debian12/debian12-server-setup.sh
        bash -n debian12/security-check.sh
        bash -n debian12/install-from-github.sh
```

### 6. Настройка Issues и Projects

1. **Включите Issues**: Settings → Features → Issues
2. **Создайте шаблоны**:
   - `.github/ISSUE_TEMPLATE/bug_report.md`
   - `.github/ISSUE_TEMPLATE/feature_request.md`

### 7. Настройка Releases

1. Перейдите в **Releases**
2. Нажмите **"Create a new release"**
3. Заполните:
   - **Tag version**: `v1.1.0`
   - **Release title**: `Debian 12 Server Setup v1.1`
   - **Description**: Скопируйте содержимое из `CHANGELOG.md`

### 8. Настройка Wiki (опционально)

1. Включите Wiki в Settings → Features
2. Создайте страницы:
   - Home
   - Installation Guide
   - Security Features
   - Troubleshooting

## 🔧 Дополнительные настройки

### Настройка веток

```bash
# Создание ветки для разработки
git checkout -b develop
git push -u origin develop

# Создание ветки для функций
git checkout -b feature/new-feature
git push -u origin feature/new-feature
```

### Настройка защиты веток

1. Settings → Branches
2. Add rule для `main`:
   - Require pull request reviews
   - Require status checks
   - Require up-to-date branches

### Настройка CODEOWNERS

Создайте файл `.github/CODEOWNERS`:

```
# Global owners
* @YOUR_USERNAME

# Debian 12 scripts
debian12/ @YOUR_USERNAME
```

## 📊 Статистика репозитория

После настройки ваш репозиторий будет содержать:

- **15 файлов** в основном коммите
- **~150KB** общего размера
- **Полная документация** на русском языке
- **Готовые скрипты** для установки
- **Архивы релизов** для скачивания

## 🚀 Команды для быстрого развертывания

```bash
# Клонирование
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Установка с GitHub
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/debian12/install-from-github.sh | bash

# Локальная установка
cd YOUR_REPO/debian12
sudo ./debian12-server-setup.sh
```

## 🔒 Безопасность репозитория

### Рекомендации:

1. **Не коммитьте пароли** - используйте переменные окружения
2. **Используйте .gitignore** - исключайте временные файлы
3. **Настройте Dependabot** - для обновления зависимостей
4. **Включите Security alerts** - для уведомлений о уязвимостях

### Настройка Dependabot:

Создайте файл `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

## 📞 Поддержка

После настройки репозитория:

1. Обновите ссылки в документации
2. Протестируйте установку с GitHub
3. Создайте первый релиз
4. Настройте мониторинг и аналитику

---

**Примечание**: Замените `YOUR_USERNAME` и `YOUR_REPO` на ваши реальные данные GitHub.
