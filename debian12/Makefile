# =============================================================================
# Makefile для управления скриптами настройки Debian 12
# Автор: DevOps Expert Team
# Версия: 1.0
# Описание: Удобные команды для работы со скриптами
# =============================================================================

# Переменные
SCRIPT_DIR := $(shell pwd)
SETUP_SCRIPT := debian12-server-setup.sh
SECURITY_SCRIPT := security-check.sh
INSTALL_SCRIPT := install-from-github.sh
CONFIG_FILE := config.env
README_FILE := README.md

# Цвета для вывода
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Основные цели
.PHONY: help install setup security check clean test validate

# Помощь
help:
	@echo -e "$(BLUE)Доступные команды:$(NC)"
	@echo -e "$(GREEN)  install$(NC)     - Установка с GitHub"
	@echo -e "$(GREEN)  setup$(NC)       - Локальная настройка сервера"
	@echo -e "$(GREEN)  security$(NC)    - Проверка безопасности"
	@echo -e "$(GREEN)  check$(NC)       - Проверка скриптов"
	@echo -e "$(GREEN)  test$(NC)        - Тестирование скриптов"
	@echo -e "$(GREEN)  validate$(NC)    - Валидация конфигурации"
	@echo -e "$(GREEN)  clean$(NC)       - Очистка временных файлов"
	@echo -e "$(GREEN)  docs$(NC)        - Генерация документации"

# Установка с GitHub
install:
	@echo -e "$(BLUE)Установка с GitHub...$(NC)"
	@if [ -f $(INSTALL_SCRIPT) ]; then \
		chmod +x $(INSTALL_SCRIPT) && \
		sudo ./$(INSTALL_SCRIPT); \
	else \
		echo -e "$(RED)Скрипт $(INSTALL_SCRIPT) не найден$(NC)"; \
		exit 1; \
	fi

# Локальная настройка
setup:
	@echo -e "$(BLUE)Локальная настройка сервера...$(NC)"
	@if [ -f $(SETUP_SCRIPT) ]; then \
		chmod +x $(SETUP_SCRIPT) && \
		sudo ./$(SETUP_SCRIPT); \
	else \
		echo -e "$(RED)Скрипт $(SETUP_SCRIPT) не найден$(NC)"; \
		exit 1; \
	fi

# Проверка безопасности
security:
	@echo -e "$(BLUE)Проверка безопасности...$(NC)"
	@if [ -f $(SECURITY_SCRIPT) ]; then \
		chmod +x $(SECURITY_SCRIPT) && \
		sudo ./$(SECURITY_SCRIPT); \
	else \
		echo -e "$(RED)Скрипт $(SECURITY_SCRIPT) не найден$(NC)"; \
		exit 1; \
	fi

# Проверка скриптов
check:
	@echo -e "$(BLUE)Проверка скриптов...$(NC)"
	@for script in $(SETUP_SCRIPT) $(SECURITY_SCRIPT) $(INSTALL_SCRIPT); do \
		if [ -f $$script ]; then \
			echo -e "$(GREEN)✓$(NC) $$script"; \
			if command -v shellcheck >/dev/null 2>&1; then \
				shellcheck $$script || echo -e "$(YELLOW)⚠$(NC) $$script имеет предупреждения"; \
			fi; \
		else \
			echo -e "$(RED)✗$(NC) $$script не найден"; \
		fi; \
	done

# Тестирование скриптов
test:
	@echo -e "$(BLUE)Тестирование скриптов...$(NC)"
	@if [ -f $(SETUP_SCRIPT) ]; then \
		echo -e "$(GREEN)Тестирование $(SETUP_SCRIPT)...$(NC)"; \
		bash -n $(SETUP_SCRIPT) && echo -e "$(GREEN)✓ Синтаксис корректен$(NC)"; \
	fi
	@if [ -f $(SECURITY_SCRIPT) ]; then \
		echo -e "$(GREEN)Тестирование $(SECURITY_SCRIPT)...$(NC)"; \
		bash -n $(SECURITY_SCRIPT) && echo -e "$(GREEN)✓ Синтаксис корректен$(NC)"; \
	fi
	@if [ -f $(INSTALL_SCRIPT) ]; then \
		echo -e "$(GREEN)Тестирование $(INSTALL_SCRIPT)...$(NC)"; \
		bash -n $(INSTALL_SCRIPT) && echo -e "$(GREEN)✓ Синтаксис корректен$(NC)"; \
	fi

# Валидация конфигурации
validate:
	@echo -e "$(BLUE)Валидация конфигурации...$(NC)"
	@if [ -f $(CONFIG_FILE) ]; then \
		echo -e "$(GREEN)✓$(NC) $(CONFIG_FILE) найден"; \
		if command -v env >/dev/null 2>&1; then \
			env -i bash -c "set -a; source $(CONFIG_FILE); set +a; echo 'Конфигурация загружена успешно'"; \
		fi; \
	else \
		echo -e "$(RED)✗$(NC) $(CONFIG_FILE) не найден"; \
	fi

# Очистка временных файлов
clean:
	@echo -e "$(BLUE)Очистка временных файлов...$(NC)"
	@find . -name "*.tmp" -delete
	@find . -name "*.log" -delete
	@find . -name "*.bak" -delete
	@echo -e "$(GREEN)Очистка завершена$(NC)"

# Генерация документации
docs:
	@echo -e "$(BLUE)Генерация документации...$(NC)"
	@if [ -f $(README_FILE) ]; then \
		echo -e "$(GREEN)✓$(NC) $(README_FILE) уже существует"; \
	else \
		echo -e "$(YELLOW)⚠$(NC) $(README_FILE) не найден"; \
	fi

# Установка зависимостей для разработки
dev-deps:
	@echo -e "$(BLUE)Установка зависимостей для разработки...$(NC)"
	@if command -v apt >/dev/null 2>&1; then \
		sudo apt update && \
		sudo apt install -y shellcheck make curl wget git; \
		echo -e "$(GREEN)Зависимости установлены$(NC)"; \
	else \
		echo -e "$(RED)apt не найден$(NC)"; \
	fi

# Проверка системы
system-check:
	@echo -e "$(BLUE)Проверка системы...$(NC)"
	@echo -e "$(GREEN)ОС:$(NC) $$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
	@echo -e "$(GREEN)Ядро:$(NC) $$(uname -r)"
	@echo -e "$(GREEN)Архитектура:$(NC) $$(uname -m)"
	@echo -e "$(GREEN)Пользователь:$(NC) $$(whoami)"
	@echo -e "$(GREEN)Директория:$(NC) $$(pwd)"

# Создание архива
archive:
	@echo -e "$(BLUE)Создание архива...$(NC)"
	@tar -czf debian12-setup-$(shell date +%Y%m%d).tar.gz \
		$(SETUP_SCRIPT) \
		$(SECURITY_SCRIPT) \
		$(INSTALL_SCRIPT) \
		$(CONFIG_FILE) \
		$(README_FILE) \
		Makefile
	@echo -e "$(GREEN)Архив создан: debian12-setup-$(shell date +%Y%m%d).tar.gz$(NC)"

# Информация о проекте
info:
	@echo -e "$(BLUE)Информация о проекте:$(NC)"
	@echo -e "$(GREEN)Название:$(NC) Скрипт настройки Debian 12"
	@echo -e "$(GREEN)Версия:$(NC) 1.0"
	@echo -e "$(GREEN)Автор:$(NC) DevOps Expert Team"
	@echo -e "$(GREEN)Описание:$(NC) Комплексная настройка и защита сервера Debian 12"
	@echo -e "$(GREEN)Файлы:$(NC)"
	@ls -la *.sh *.env *.md Makefile 2>/dev/null || echo "Файлы не найдены"

# Быстрая установка (все в одном)
quick-install: check test validate setup security
	@echo -e "$(GREEN)Быстрая установка завершена!$(NC)"

# По умолчанию показываем помощь
.DEFAULT_GOAL := help

