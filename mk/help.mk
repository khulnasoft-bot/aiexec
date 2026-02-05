######################
# HELP COMMANDS
######################

help_backend: ## show backend-specific commands
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)                    BACKEND COMMANDS                               $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
	@echo "$(GREEN)Installation & Dependencies:$(NC)"
	@echo "  $(GREEN)make install_backend$(NC)     - Install backend dependencies"
	@echo "  $(GREEN)make reinstall_backend$(NC)   - Force reinstall backend dependencies"
	@echo "  $(GREEN)make setup_uv$(NC)            - Install uv using pipx"
	@echo "  $(GREEN)make add$(NC)                 - Add dependencies (use: make add main=\"pkg\" or base=\"pkg\")"
	@echo ''
	@echo "$(GREEN)Development:$(NC)"
	@echo "  $(GREEN)make backend$(NC)             - Run backend in development mode"
	@echo "  $(GREEN)make run_cli$(NC)             - Run Primeagent CLI"
	@echo "  $(GREEN)make run_clic$(NC)            - Run CLI with fresh frontend build"
	@echo "  $(GREEN)make run_cli_debug$(NC)       - Run CLI in debug mode"
	@echo "  $(GREEN)make setup_devcontainer$(NC)  - Set up development container"
	@echo "  $(GREEN)make setup_env$(NC)           - Set up environment variables"
	@echo ''
	@echo "$(GREEN)Code Quality:$(NC)"
	@echo "  $(GREEN)make format_backend$(NC)      - Format backend code (ruff)"
	@echo "  $(GREEN)make format_frontend_check$(NC) - Check frontend formatting (biome)"
	@echo "  $(GREEN)make lint$(NC)                - Run backend linters (mypy)"
	@echo "  $(GREEN)make codespell$(NC)           - Check spelling errors"
	@echo "  $(GREEN)make fix_codespell$(NC)       - Fix spelling errors automatically"
	@echo "  $(GREEN)make unsafe_fix$(NC)          - Run ruff with unsafe fixes"
	@echo ''
	@echo "$(GREEN)Database (Alembic):$(NC)"
	@echo "  $(GREEN)make alembic-revision message=\"text\"$(NC) - Generate new migration"
	@echo "  $(GREEN)make alembic-upgrade$(NC)     - Upgrade database to latest version"
	@echo "  $(GREEN)make alembic-downgrade$(NC)   - Downgrade database by one version"
	@echo "  $(GREEN)make alembic-current$(NC)     - Show current database revision"
	@echo "  $(GREEN)make alembic-history$(NC)     - Show migration history"
	@echo "  $(GREEN)make alembic-check$(NC)       - Check migration status"
	@echo "  $(GREEN)make alembic-stamp$(NC)       - Stamp database with specific revision"
	@echo ''
	@echo "$(GREEN)Build & Distribution:$(NC)"
	@echo "  $(GREEN)make build$(NC)               - Build the project"
	@echo "  $(GREEN)make build_and_run$(NC)       - Build and run the project"
	@echo "  $(GREEN)make build_and_install$(NC)   - Build and install the project"
	@echo "  $(GREEN)make build_primeagent_base$(NC) - Build primeagent-base package"
	@echo "  $(GREEN)make build_primeagent$(NC)      - Build primeagent package"
	@echo "  $(GREEN)make lock$(NC)                - Lock dependencies"
	@echo "  $(GREEN)make update$(NC)              - Update dependencies"
	@echo "  $(GREEN)make publish$(NC)             - Publish to PyPI"
	@echo ''
	@echo "$(GREEN)WFX Package Commands:$(NC)"
	@echo "  $(GREEN)make wfx_build$(NC)           - Build WFX package"
	@echo "  $(GREEN)make wfx_tests$(NC)           - Run WFX tests"
	@echo "  $(GREEN)make wfx_format$(NC)          - Format WFX code"
	@echo "  $(GREEN)make wfx_lint$(NC)            - Lint WFX code"
	@echo "  $(GREEN)make wfx_clean$(NC)           - Clean WFX build artifacts"
	@echo "  $(GREEN)make wfx_publish$(NC)         - Publish WFX to PyPI"
	@echo "  $(GREEN)make wfx_docker_build$(NC)    - Build WFX Docker image"
	@echo "  $(GREEN)make wfx_docker_dev$(NC)      - Start WFX development environment"
	@echo "  $(GREEN)make wfx_docker_test$(NC)     - Run WFX tests in Docker"
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''

help_test: ## show testing commands
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)                    TESTING COMMANDS                               $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
	@echo "$(GREEN)Backend Unit Tests:$(NC)"
	@echo "  $(GREEN)make unit_tests$(NC)          - Run backend unit tests"
	@echo "  $(GREEN)make unit_tests_looponfail$(NC) - Run unit tests with loop on fail"
	@echo "  $(GREEN)make wfx_tests$(NC)           - Run WFX package tests"
	@echo ''
	@echo "$(GREEN)Backend Integration Tests:$(NC)"
	@echo "  $(GREEN)make integration_tests$(NC)   - Run all integration tests"
	@echo "  $(GREEN)make integration_tests_no_api_keys$(NC) - Run integration tests without API keys"
	@echo "  $(GREEN)make integration_tests_api_keys$(NC) - Run integration tests requiring API keys"
	@echo ''
	@echo "$(GREEN)Template Tests:$(NC)"
	@echo "  $(GREEN)make template_tests$(NC)      - Run starter project template tests"
	@echo ''
	@echo "$(GREEN)Combined Tests:$(NC)"
	@echo "  $(GREEN)make tests$(NC)               - Run all tests (unit + integration + coverage)"
	@echo "  $(GREEN)make coverage$(NC)            - Run tests and generate coverage report"
	@echo ''
	@echo "$(GREEN)Frontend Tests:$(NC)"
	@echo "  $(GREEN)make tests_frontend$(NC)      - Run Playwright e2e tests"
	@echo "  $(GREEN)make test_frontend$(NC)       - Run Jest unit tests"
	@echo "  $(GREEN)make test_frontend_watch$(NC) - Run Jest tests in watch mode"
	@echo "  $(GREEN)make test_frontend_coverage$(NC) - Run Jest with coverage"
	@echo "  $(GREEN)make test_frontend_coverage_open$(NC) - Run coverage and open report"
	@echo "  $(GREEN)make test_frontend_verbose$(NC) - Run Jest with verbose output"
	@echo "  $(GREEN)make test_frontend_ci$(NC)    - Run Jest in CI mode"
	@echo "  $(GREEN)make test_frontend_clean$(NC) - Clean cache and run Jest"
	@echo "  $(GREEN)make test_frontend_bail$(NC)  - Run Jest with bail (stop on first failure)"
	@echo "  $(GREEN)make test_frontend_silent$(NC) - Run Jest silently"
	@echo "  $(GREEN)make test_frontend_file path$(NC) - Run tests for specific file"
	@echo "  $(GREEN)make test_frontend_pattern pattern$(NC) - Run tests matching pattern"
	@echo "  $(GREEN)make test_frontend_snapshots$(NC) - Update Jest snapshots"
	@echo "  $(GREEN)make test_frontend_config$(NC) - Show Jest configuration"
	@echo ''
	@echo "$(GREEN)Load Testing:$(NC)"
	@echo "  $(GREEN)make locust$(NC)              - Run locust load tests"
	@echo "    Options: locust_users=10 locust_spawn_rate=1 locust_host=http://localhost:7860"
	@echo "             locust_headless=true locust_time=300s locust_api_key=key"
	@echo "             locust_flow_id=id locust_file=path"
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''

help_docker: ## show docker commands
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)                    DOCKER COMMANDS                                $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
	@echo "$(GREEN)Docker Build:$(NC)"
	@echo "  $(GREEN)make docker_build$(NC)        - Build main Docker image"
	@echo "  $(GREEN)make docker_build_backend$(NC) - Build backend Docker image"
	@echo "  $(GREEN)make docker_build_frontend$(NC) - Build frontend Docker image"
	@echo ''
	@echo "$(GREEN)Docker Compose:$(NC)"
	@echo "  $(GREEN)make docker_compose_up$(NC)   - Build and start docker compose"
	@echo "  $(GREEN)make docker_compose_down$(NC) - Stop docker compose"
	@echo "  $(GREEN)make dcdev_up$(NC)            - Start development docker compose"
	@echo ''
	@echo "$(GREEN)WFX Docker:$(NC)"
	@echo "  $(GREEN)make wfx_docker_build$(NC)    - Build WFX production Docker image"
	@echo "  $(GREEN)make wfx_docker_dev$(NC)      - Start WFX development environment"
	@echo "  $(GREEN)make wfx_docker_test$(NC)     - Run WFX tests in Docker"
	@echo ''
	@echo "$(GREEN)Note:$(NC) By default, these commands use $(GREEN)podman$(NC)."
	@echo "      To use Docker instead: $(GREEN)make docker_build DOCKER=docker$(NC)"
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''

help_advanced: ## show advanced and miscellaneous commands
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)                    ADVANCED COMMANDS                              $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
	@echo "$(GREEN)Cleanup:$(NC)"
	@echo "  $(GREEN)make clean_all$(NC)           - Clean all caches and temporary directories"
	@echo "  $(GREEN)make clean_python_cache$(NC)  - Clean Python cache files"
	@echo "  $(GREEN)make clean_npm_cache$(NC)     - Clean npm cache and node_modules"
	@echo "  $(GREEN)make clean_frontend_build$(NC) - Clean frontend build artifacts"
	@echo ''
	@echo "$(GREEN)Version Management:$(NC)"
	@echo "  $(GREEN)make patch v=X.Y.Z$(NC)       - Update version across all projects"
	@echo "    Example: make patch v=1.5.0"
	@echo "    This updates: pyproject.toml, primeagent-base, frontend package.json"
	@echo ''
	@echo "$(GREEN)Publishing:$(NC)"
	@echo "  $(GREEN)make publish$(NC)             - Publish to PyPI (use: make publish base=1 or main=1)"
	@echo "  $(GREEN)make publish_testpypi$(NC)    - Publish to test PyPI"
	@echo "  $(GREEN)make publish_base$(NC)        - Publish primeagent-base to PyPI"
	@echo "  $(GREEN)make publish_primeagent$(NC)    - Publish primeagent to PyPI"
	@echo "  $(GREEN)make wfx_publish$(NC)         - Publish WFX package to PyPI"
	@echo "  $(GREEN)make wfx_publish_testpypi$(NC) - Publish WFX to test PyPI"
	@echo ''
	@echo "$(GREEN)Lock Files:$(NC)"
	@echo "  $(GREEN)make lock$(NC)                - Lock all dependencies"
	@echo "  $(GREEN)make lock_base$(NC)           - Lock primeagent-base dependencies"
	@echo "  $(GREEN)make lock_primeagent$(NC)       - Lock primeagent dependencies"
	@echo ''
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  $(GREEN)make check_tools$(NC)         - Verify required tools are installed"
	@echo "  $(GREEN)make clear_dockerimage$(NC)   - Clear dangling Docker images"
	@echo ''
	@echo "$(GREEN)Backend Configuration:$(NC)"
	@echo "  Backend commands support these variables:"
	@echo "    log_level=debug host=0.0.0.0 port=7860 env=.env"
	@echo "    workers=1 open_browser=true async=true"
	@echo "  Example: $(GREEN)make backend port=8080 workers=4$(NC)"
	@echo ''
	@echo "$(GREEN)Unit Tests Configuration:$(NC)"
	@echo "  Unit test commands support these variables:"
	@echo "    async=true lf=true ff=true"
	@echo "  Example: $(GREEN)make unit_tests async=false$(NC)"
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
