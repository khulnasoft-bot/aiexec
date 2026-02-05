######################
# DOCUMENTATION TARGETS
######################

docs_port ?= 3030

check_pnpm:
	@command -v pnpm >/dev/null 2>&1 || { \
		echo "$(RED)Error: pnpm is not installed.$(NC)"; \
		echo "$(YELLOW)The docs project requires pnpm. Please install it:$(NC)"; \
		echo "  npm install -g pnpm"; \
		exit 1; \
	}

docs_install: check_pnpm ## install documentation dependencies
	@echo "$(GREEN)Installing documentation dependencies...$(NC)"
	@cd docs && pnpm install

docs: docs_install ## start documentation development server (default port 3030)
	@echo "$(GREEN)Starting documentation server at http://localhost:$(docs_port)$(NC)"
	@cd docs && pnpm start --port $(docs_port)

docs_build: docs_install ## build documentation for production
	@echo "$(GREEN)Building documentation...$(NC)"
	@cd docs && pnpm build
	@echo "$(GREEN)Documentation built successfully in docs/build/$(NC)"

docs_serve: docs_build ## build and serve documentation locally
	@echo "$(GREEN)Serving built documentation...$(NC)"
	@cd docs && pnpm serve --port $(docs_port)
