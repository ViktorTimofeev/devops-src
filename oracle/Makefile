# =============================================================================
# Makefile для управления Oracle Database 11.2.0.4.0
# Автор: DevOps Expert Team
# Версия: 1.0
# Описание: Автоматизация задач управления Oracle
# =============================================================================

# Переменные Oracle
ORACLE_BASE := /opt/oracle
ORACLE_HOME := /opt/oracle/product/11.2.0/dbhome_1
ORACLE_SID := orcl
ORACLE_USER := oracle
ORACLE_GROUP := oinstall

# Цвета для вывода
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Функции логирования
define log
	@echo -e "$(GREEN)[$(shell date '+%Y-%m-%d %H:%M:%S')]$(NC) $(1)"
endef

define log_error
	@echo -e "$(RED)[$(shell date '+%Y-%m-%d %H:%M:%S')] ERROR:$(NC) $(1)"
endef

define log_warning
	@echo -e "$(YELLOW)[$(shell date '+%Y-%m-%d %H:%M:%S')] WARNING:$(NC) $(1)"
endef

define log_info
	@echo -e "$(BLUE)[$(shell date '+%Y-%m-%d %H:%M:%S')] INFO:$(NC) $(1)"
endef

# Проверка прав root
check-root:
	@if [ $$(id -u) -ne 0 ]; then \
		$(call log_error,"Этот скрипт должен запускаться с правами root"); \
		exit 1; \
	fi

# Проверка пользователя oracle
check-oracle:
	@if ! id $(ORACLE_USER) >/dev/null 2>&1; then \
		$(call log_error,"Пользователь $(ORACLE_USER) не найден"); \
		exit 1; \
	fi

# Установка Oracle
install: check-root
	$(call log,"Начинаем установку Oracle Database 11.2.0.4.0...")
	@chmod +x oracle-11g-install.sh
	@./oracle-11g-install.sh
	$(call log,"Установка Oracle завершена!")

# Проверка установки Oracle
check: check-oracle
	$(call log,"Начинаем проверку установки Oracle...")
	@chmod +x oracle-check.sh
	@./oracle-check.sh
	$(call log,"Проверка Oracle завершена!")

# Запуск Oracle Database
start-db: check-oracle
	$(call log,"Запуск Oracle Database...")
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); $(ORACLE_HOME)/bin/sqlplus -s / as sysdba << 'EOF'"
	@echo "STARTUP;"
	@echo "EXIT;"
	@echo "EOF"
	$(call log,"Oracle Database запущена!")

# Остановка Oracle Database
stop-db: check-oracle
	$(call log,"Остановка Oracle Database...")
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); $(ORACLE_HOME)/bin/sqlplus -s / as sysdba << 'EOF'"
	@echo "SHUTDOWN IMMEDIATE;"
	@echo "EXIT;"
	@echo "EOF"
	$(call log,"Oracle Database остановлена!")

# Перезапуск Oracle Database
restart-db: stop-db start-db
	$(call log,"Oracle Database перезапущена!")

# Запуск Oracle Listener
start-listener: check-oracle
	$(call log,"Запуск Oracle Listener...")
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); $(ORACLE_HOME)/bin/lsnrctl start"
	$(call log,"Oracle Listener запущен!")

# Остановка Oracle Listener
stop-listener: check-oracle
	$(call log,"Остановка Oracle Listener...")
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); $(ORACLE_HOME)/bin/lsnrctl stop"
	$(call log,"Oracle Listener остановлен!")

# Перезапуск Oracle Listener
restart-listener: stop-listener start-listener
	$(call log,"Oracle Listener перезапущен!")

# Статус Oracle
status: check-oracle
	$(call log,"Проверка статуса Oracle...")
	@echo "=== Статус процессов Oracle ==="
	@ps aux | grep oracle | grep -v grep || echo "Процессы Oracle не найдены"
	@echo ""
	@echo "=== Статус портов Oracle ==="
	@netstat -tlnp | grep -E ":1521|:1158" || echo "Порты Oracle не открыты"
	@echo ""
	@echo "=== Статус Listener ==="
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); $(ORACLE_HOME)/bin/lsnrctl status" 2>/dev/null || echo "Listener недоступен"
	@echo ""
	@echo "=== Статус базы данных ==="
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); echo 'SELECT instance_name, status FROM v\$$instance;' | $(ORACLE_HOME)/bin/sqlplus -s / as sysdba" 2>/dev/null || echo "База данных недоступна"

# Подключение к Oracle
connect: check-oracle
	$(call log,"Подключение к Oracle Database...")
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); $(ORACLE_HOME)/bin/sqlplus / as sysdba"

# Создание резервной копии
backup: check-oracle
	$(call log,"Создание резервной копии Oracle Database...")
	@mkdir -p $(ORACLE_BASE)/backup
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); $(ORACLE_HOME)/bin/rman target / << 'EOF'"
	@echo "BACKUP DATABASE PLUS ARCHIVELOG;"
	@echo "EXIT;"
	@echo "EOF"
	$(call log,"Резервная копия создана!")

# Очистка логов Oracle
clean-logs: check-oracle
	$(call log,"Очистка логов Oracle...")
	@find $(ORACLE_BASE)/diag -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true
	@find $(ORACLE_BASE)/diag -name "*.trc" -type f -mtime +30 -delete 2>/dev/null || true
	$(call log,"Логи Oracle очищены!")

# Установка прав на файлы Oracle
fix-permissions: check-root
	$(call log,"Исправление прав на файлы Oracle...")
	@chown -R $(ORACLE_USER):$(ORACLE_GROUP) $(ORACLE_BASE)
	@chmod -R 755 $(ORACLE_BASE)
	@chown -R $(ORACLE_USER):$(ORACLE_GROUP) /opt/oraInventory
	@chmod -R 755 /opt/oraInventory
	$(call log,"Права на файлы Oracle исправлены!")

# Настройка автоматического запуска Oracle
setup-autostart: check-root
	$(call log,"Настройка автоматического запуска Oracle...")
	@cat > /etc/systemd/system/oracle-db.service << 'EOF'
[Unit]
Description=Oracle Database 11g
After=network.target

[Service]
Type=forking
User=$(ORACLE_USER)
Group=$(ORACLE_GROUP)
Environment=ORACLE_HOME=$(ORACLE_HOME)
Environment=ORACLE_SID=$(ORACLE_SID)
ExecStart=$(ORACLE_HOME)/bin/dbstart $(ORACLE_HOME)
ExecStop=$(ORACLE_HOME)/bin/dbshut $(ORACLE_HOME)
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF
	@systemctl daemon-reload
	@systemctl enable oracle-db.service
	$(call log,"Автоматический запуск Oracle настроен!")

# Отключение автоматического запуска Oracle
disable-autostart: check-root
	$(call log,"Отключение автоматического запуска Oracle...")
	@systemctl disable oracle-db.service 2>/dev/null || true
	@rm -f /etc/systemd/system/oracle-db.service
	@systemctl daemon-reload
	$(call log,"Автоматический запуск Oracle отключен!")

# Мониторинг Oracle
monitor: check-oracle
	$(call log,"Мониторинг Oracle Database...")
	@echo "=== Использование памяти ==="
	@free -h
	@echo ""
	@echo "=== Использование диска ==="
	@df -h $(ORACLE_BASE)
	@echo ""
	@echo "=== Процессы Oracle ==="
	@ps aux | grep oracle | grep -v grep | wc -l | xargs echo "Количество процессов Oracle:"
	@echo ""
	@echo "=== Активные сессии ==="
	@sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); echo 'SELECT COUNT(*) as active_sessions FROM v\$$session WHERE status = '\''ACTIVE'\'';' | $(ORACLE_HOME)/bin/sqlplus -s / as sysdba" 2>/dev/null || echo "Не удалось получить информацию о сессиях"

# Обновление паролей Oracle
change-passwords: check-oracle
	$(call log,"Обновление паролей Oracle...")
	@echo "Введите новый пароль для пользователей Oracle:"
	@read -s -p "Новый пароль: " NEW_PASSWORD; \
	echo ""; \
	echo "Подтвердите пароль:"; \
	read -s -p "Подтверждение: " CONFIRM_PASSWORD; \
	if [ "$$NEW_PASSWORD" = "$$CONFIRM_PASSWORD" ]; then \
		sudo -u $(ORACLE_USER) bash -c "export ORACLE_HOME=$(ORACLE_HOME); export ORACLE_SID=$(ORACLE_SID); $(ORACLE_HOME)/bin/sqlplus -s / as sysdba << 'EOF'"; \
		echo "ALTER USER sys IDENTIFIED BY \"$$NEW_PASSWORD\";"; \
		echo "ALTER USER system IDENTIFIED BY \"$$NEW_PASSWORD\";"; \
		echo "ALTER USER sysman IDENTIFIED BY \"$$NEW_PASSWORD\";"; \
		echo "ALTER USER dbsnmp IDENTIFIED BY \"$$NEW_PASSWORD\";"; \
		echo "EXIT;"; \
		echo "EOF"; \
		$(call log,"Пароли Oracle обновлены!"); \
	else \
		$(call log_error,"Пароли не совпадают!"); \
	fi

# Показать справку
help:
	@echo "Доступные команды для управления Oracle Database 11.2.0.4.0:"
	@echo ""
	@echo "Установка и проверка:"
	@echo "  install          - Установка Oracle Database"
	@echo "  check            - Проверка установки Oracle"
	@echo ""
	@echo "Управление базой данных:"
	@echo "  start-db         - Запуск Oracle Database"
	@echo "  stop-db          - Остановка Oracle Database"
	@echo "  restart-db       - Перезапуск Oracle Database"
	@echo "  connect          - Подключение к Oracle Database"
	@echo ""
	@echo "Управление Listener:"
	@echo "  start-listener   - Запуск Oracle Listener"
	@echo "  stop-listener    - Остановка Oracle Listener"
	@echo "  restart-listener - Перезапуск Oracle Listener"
	@echo ""
	@echo "Мониторинг и обслуживание:"
	@echo "  status           - Статус Oracle"
	@echo "  monitor          - Мониторинг Oracle"
	@echo "  backup           - Создание резервной копии"
	@echo "  clean-logs        - Очистка логов Oracle"
	@echo ""
	@echo "Настройка системы:"
	@echo "  fix-permissions  - Исправление прав на файлы"
	@echo "  setup-autostart  - Настройка автоматического запуска"
	@echo "  disable-autostart - Отключение автоматического запуска"
	@echo "  change-passwords - Обновление паролей Oracle"
	@echo ""
	@echo "Справка:"
	@echo "  help             - Показать эту справку"
	@echo ""
	@echo "Примеры использования:"
	@echo "  make install     - Установить Oracle"
	@echo "  make status      - Проверить статус"
	@echo "  make start-db    - Запустить базу данных"
	@echo "  make backup      - Создать резервную копию"

# Цель по умолчанию
.DEFAULT_GOAL := help

# Флаг для игнорирования ошибок
.PHONY: install check start-db stop-db restart-db start-listener stop-listener restart-listener status connect backup clean-logs fix-permissions setup-autostart disable-autostart monitor change-passwords help check-root check-oracle
