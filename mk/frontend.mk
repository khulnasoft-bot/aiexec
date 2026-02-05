######################
# FRONTEND TARGETS
######################

install_frontend: ## install frontend dependencies
	cd src/frontend && pnpm install

install_frontendci: ## install frontend dependencies for CI
	cd src/frontend && pnpm install --frozen-lockfile

build_frontend: ## build the frontend
	cd src/frontend && pnpm build
	rm -rf src/backend/base/primeagent/frontend
	cp -r src/frontend/build src/backend/base/primeagent/frontend

format_frontend: ## format frontend code
	cd src/frontend && pnpm format

lint_frontend: ## lint frontend code
	cd src/frontend && pnpm lint

help_frontend: ## show frontend commands
	@echo ''
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)                    FRONTEND COMMANDS                              $(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════════$(NC)"
	@echo ''
	@echo "  $(GREEN)make install_frontend$(NC)    - Install frontend dependencies"
	@echo "  $(GREEN)make install_frontendci$(NC)  - Install frontend dependencies (CI)"
	@echo "  $(GREEN)make build_frontend$(NC)      - Build frontend and copy to backend"
	@echo "  $(GREEN)make format_frontend$(NC)     - Format frontend code"
	@echo "  $(GREEN)make lint_frontend$(NC)       - Lint frontend code"
	@echo ''
