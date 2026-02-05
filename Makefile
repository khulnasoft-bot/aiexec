.PHONY: all init format_backend format lint build run_backend dev help tests coverage clean_python_cache clean_npm_cache clean_frontend_build clean_all run_clic load_test_setup load_test_setup_basic load_test_list_flows load_test_run load_test_primeagent_quick load_test_stress load_test_example load_test_clean load_test_remote_setup load_test_remote_run load_test_help docs docs_build docs_install

# Configurations
VERSION=$(shell grep "^version" pyproject.toml | sed 's/.*\"\(.*\)\"$$/\1/')
DOCKER=podman
DOCKERFILE=docker/build_and_push.Dockerfile
DOCKERFILE_BACKEND=docker/build_and_push_backend.Dockerfile
DOCKERFILE_FRONTEND=docker/frontend/build_and_push_frontend.Dockerfile
DOCKER_COMPOSE=docker_example/docker-compose.yml
PYTHON_REQUIRED=$(shell grep '^requires-python[[:space:]]*=' pyproject.toml | sed -n 's/.*"\([^"]*\)".*/\1/p')
RED=\033[0;31m
NC=\033[0m # No Color
NC_BOLD=\033[1m
GREEN=\033[0;32m
YELLOW=\033[1;33m

log_level ?= debug
host ?= 0.0.0.0
port ?= 7860
env ?= .env
open_browser ?= true
path = src/backend/base/primeagent/frontend
workers ?= 1
async ?= true
lf ?= false
ff ?= true
all: help

######################
# UTILITIES
######################

# Some directories may be mount points as in devcontainer, so we need to clear their
# contents rather than remove the entire directory. But we must also be mindful that
# we are not running in a devcontainer, so need to ensure the directories exist.
# See https://code.visualstudio.com/remote/advancedcontainers/improve-performance
CLEAR_DIRS = $(foreach dir,$1,$(shell mkdir -p $(dir) && find $(dir) -mindepth 1 -delete))

# check for required tools
check_tools:
	@command -v uv >/dev/null 2>&1 || { echo >&2 "$(RED)uv is not installed. Aborting.$(NC)"; exit 1; }
	@command -v pnpm >/dev/null 2>&1 || { echo >&2 "$(RED)pnpm is not installed. Aborting.$(NC)"; exit 1; }
	@echo "$(GREEN)All required tools are installed.$(NC)"

help: ## show basic help message with common commands
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)                    PRIMEAGENT MAKEFILE COMMANDS                     $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
	@echo "$(GREEN)Basic Commands:$(NC)"
	@echo "  $(GREEN)make init$(NC)                - Initialize project (install all dependencies)"
	@echo "  $(GREEN)make run_cli$(NC)             - Run Primeagent CLI"
	@echo "  $(GREEN)make run_clic$(NC)            - Run CLI with fresh frontend build"
	@echo "  $(GREEN)make format$(NC)              - Format all code (backend + frontend)"
	@echo "  $(GREEN)make tests$(NC)               - Run all tests"
	@echo "  $(GREEN)make build$(NC)               - Build the project"
	@echo "  $(GREEN)make docs$(NC)                - Start documentation server (http://localhost:3030)"
	@echo "  $(GREEN)make clean_all$(NC)           - Clean all caches and build artifacts"
	@echo ''
	@echo "$(GREEN)Specialized Help Commands:$(NC)"
	@echo "  $(GREEN)make help_backend$(NC)        - Show backend-specific commands"
	@echo "  $(GREEN)make help_frontend$(NC)       - Show frontend-specific commands"
	@echo "  $(GREEN)make help_test$(NC)           - Show testing commands"
	@echo "  $(GREEN)make help_docker$(NC)         - Show Docker commands"
	@echo "  $(GREEN)make help_advanced$(NC)       - Show advanced/miscellaneous commands"
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''

######################
# INSTALL PROJECT
######################

init: check_tools ## initialize the project
	@make install_backend
	@make install_frontend
	@uvx pre-commit install
	@echo "$(GREEN)All requirements are installed.$(NC)"

######################
# CLEAN PROJECT
######################

clean_python_cache:
	@echo "Cleaning Python cache..."
	find . -type d -name '__pycache__' -exec rm -r {} +
	find . -type f -name '*.py[cod]' -exec rm -f {} +
	find . -type f -name '*~' -exec rm -f {} +
	find . -type f -name '.*~' -exec rm -f {} +
	$(call CLEAR_DIRS,.mypy_cache )
	@echo "$(GREEN)Python cache cleaned.$(NC)"

clean_npm_cache:
	@echo "Cleaning pnpm cache..."
	cd src/frontend && pnpm store prune
	$(call CLEAR_DIRS,src/frontend/node_modules src/frontend/build src/backend/base/primeagent/frontend)
	rm -f src/frontend/pnpm-lock.yaml
	@echo "$(GREEN)pnpm cache and frontend directories cleaned.$(NC)"

clean_frontend_build: ## clean frontend build artifacts to ensure fresh build
	@echo "Cleaning frontend build artifacts..."
	@echo "  - Removing src/frontend/build directory"
	$(call CLEAR_DIRS,src/frontend/build)
	@echo "  - Removing built frontend files from backend"
	$(call CLEAR_DIRS,src/backend/base/primeagent/frontend)
	@echo "$(GREEN)Frontend build artifacts cleaned - fresh build guaranteed.$(NC)"

clean_all: clean_python_cache clean_npm_cache # clean all caches and temporary directories
	@echo "$(GREEN)All caches and temporary directories cleaned.$(NC)"

setup_uv: ## install uv using pipx
	pipx install uv

######################
# CODE TESTS & QUALITY
######################

tests: ## run unit, integration, coverage tests
	@echo 'Running Unit Tests...'
	make unit_tests
	@echo 'Running Integration Tests...'
	make integration_tests
	@echo 'Running Coverage Tests...'
	make coverage

template_tests: ## run all starter project template tests
	@echo 'Running Starter Project Template Tests...'
	@uv run pytest src/backend/tests/unit/template/test_starter_projects.py -v -n auto

codespell: ## run codespell to check spelling
	@uvx codespell --toml pyproject.toml

fix_codespell: ## run codespell to fix spelling errors
	@uvx codespell --toml pyproject.toml --write

format: format_backend format_frontend ## run code formatters

format_frontend_check: ## run biome check without formatting
	@echo 'Running Biome check on frontend...'
	@cd src/frontend && pnpm exec biome check

######################
# RUN & BUILD
######################

run_clic: clean_frontend_build install_frontend install_backend build_frontend ## run the CLI with fresh frontend build
	@echo 'Running the CLI with fresh frontend build'
	@uv run primeagent run \
		--frontend-path $(path) \
		--log-level $(log_level) \
		--host $(host) \
		--port $(port) \
		$(if $(env),--env-file $(env),) \
		$(if $(filter false,$(open_browser)),--no-open-browser)

run_cli: install_frontend install_backend build_frontend ## run the CLI quickly (without cleaning build cache)
	@echo 'Running the CLI quickly (reusing existing build cache if available)'
	@uv run primeagent run \
		--frontend-path $(path) \
		--log-level $(log_level) \
		--host $(host) \
		--port $(port) \
		$(if $(env),--env-file $(env),) \
		$(if $(filter false,$(open_browser)),--no-open-browser)

run_cli_debug:
	@echo 'Running the CLI in debug mode'
	@make install_frontend > /dev/null
	@echo 'Building the frontend'
	@make build_frontend > /dev/null
	@echo 'Install backend dependencies'
	@make install_backend > /dev/null
ifdef env
	@make start env=$(env) host=$(host) port=$(port) log_level=debug
else
	@make start host=$(host) port=$(port) log_level=debug
endif

setup_devcontainer: ## set up the development container
	make install_backend
	make install_frontend
	make build_frontend
	uv run primeagent --frontend-path src/frontend/build

setup_env: ## set up the environment
	@sh ./scripts/setup/setup_env.sh

build_and_run: setup_env ## build the project and run it
	$(call CLEAR_DIRS,dist src/backend/base/dist)
	make build
	uv run pip install dist/*.tar.gz
	uv run primeagent run

build_and_install: ## build the project and install it
	@echo 'Removing dist folder'
	$(call CLEAR_DIRS,dist src/backend/base/dist)
	make build && uv run pip install dist/*.whl && pip install src/backend/base/dist/*.whl --force-reinstall

build: setup_env ## build the frontend static files and package the project
ifdef base
	make install_frontendci
	make build_frontend
	make build_primeagent_base args="$(args)"
endif

ifdef main
	make install_frontendci
	make build_frontend
	make build_primeagent_base args="$(args)"
	make build_primeagent args="$(args)"
endif

build_primeagent_base:
	cd src/backend/base && uv build $(args)

build_primeagent:
	uv lock --no-upgrade
	uv build $(args)

######################
# INCLUDE MODULAR MAKEFILES
######################

include mk/frontend.mk
include mk/backend.mk
include mk/docker.mk
include mk/alembic.mk
include mk/wfx.mk
include mk/version.mk
include mk/load_test.mk
include mk/docs.mk
include mk/help.mk

######################
# HELP COMMANDS
######################

# help_backend, help_test, help_docker, help_advanced are now in their respective mk files or inherited
# We'll keep them here or move them to mk files if they are specific.
# Actually, I'll keep the help commands in the main Makefile for now or move them to a help.mk if it gets too long.
# For now, I'll leave the help commands as they were in the original file but cleaned up.

# (Rest of help commands from lines 831-1014 if they were not moved)
# I'll move them to mk/help.mk to keep the main Makefile clean.
