######################
# WFX PACKAGE TARGETS
######################

wfx_tests: ## run wfx package unit tests
	@echo 'Running WFX Package Tests...'
	@cd src/wfx && \
	uv sync && \
	uv run pytest tests/unit -v --cov=src/wfx --cov-report=xml --cov-report=html --cov-report=term-missing $(args)

build_component_index: ## build the component index with dynamic loading
	@echo 'Installing backend dependencies for building component index'
	@make install_backend
	@echo 'Building component index'
	WFX_DEV=1 uv run python scripts/build_component_index.py

wfx_build: ## build the WFX package
	@echo 'Building WFX package'
	@cd src/wfx && make build

wfx_publish: ## publish WFX package to PyPI
	@echo 'Publishing WFX package'
	@cd src/wfx && make publish

wfx_publish_testpypi: ## publish WFX package to test PyPI
	@echo 'Publishing WFX package to test PyPI'
	@cd src/wfx && make publish_test

wfx_test: ## run WFX tests
	@echo 'Running WFX tests'
	@cd src/wfx && make test

wfx_format: ## format WFX code
	@echo 'Formatting WFX code'
	@cd src/wfx && make format

wfx_lint: ## lint WFX code
	@echo 'Linting WFX code'
	@cd src/wfx && make lint

wfx_clean: ## clean WFX build artifacts
	@echo 'Cleaning WFX build artifacts'
	@cd src/wfx && make clean

wfx_docker_build: ## build WFX production Docker image
	@echo 'Building WFX Docker image'
	@cd src/wfx && make docker_build

wfx_docker_dev: ## start WFX development environment
	@echo 'Starting WFX development environment'
	@cd src/wfx && make docker_dev

wfx_docker_test: ## run WFX tests in Docker
	@echo 'Running WFX tests in Docker'
	@cd src/wfx && make docker_test
