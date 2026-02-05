######################
# ALEMBIC TARGETS
######################

# example make alembic-revision message="Add user table"
alembic-revision: ## generate a new migration
	@echo 'Generating a new Alembic revision'
	cd src/backend/base/primeagent/ && uv run alembic revision --autogenerate -m "$(message)"

alembic-upgrade: ## upgrade database to the latest version
	@echo 'Upgrading database to the latest version'
	cd src/backend/base/primeagent/ && uv run alembic upgrade head

alembic-downgrade: ## downgrade database by one version
	@echo 'Downgrading database by one version'
	cd src/backend/base/primeagent/ && uv run alembic downgrade -1

alembic-current: ## show current revision
	@echo 'Showing current Alembic revision'
	cd src/backend/base/primeagent/ && uv run alembic current

alembic-history: ## show migration history
	@echo 'Showing Alembic migration history'
	cd src/backend/base/primeagent/ && uv run alembic history --verbose

alembic-check: ## check migration status
	@echo 'Running alembic check'
	cd src/backend/base/primeagent/ && uv run alembic check

alembic-stamp: ## stamp the database with a specific revision
	@echo 'Stamping the database with revision $(revision)'
	cd src/backend/base/primeagent/ && uv run alembic stamp $(revision)
