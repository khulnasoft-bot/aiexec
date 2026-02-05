######################
# VERSION & PUBLISHING TARGETS
######################

patch: ## Update version across all projects. Usage: make patch v=1.5.0
	@if [ -z "$(v)" ]; then \
		echo "$(RED)Error: Version argument required.$(NC)"; \
		echo "Usage: make patch v=1.5.0"; \
		exit 1; \
	fi; \
	echo "$(GREEN)Updating version to $(v)$(NC)"; \
	\
	PRIMEAGENT_VERSION="$(v)"; \
	PRIMEAGENT_BASE_VERSION=$$(echo "$$PRIMEAGENT_VERSION" | sed -E 's/^[0-9]+\.(.*)$$/0.\1/'); \
	\
	echo "$(GREEN)Primeagent version: $$PRIMEAGENT_VERSION$(NC)"; \
	echo "$(GREEN)Primeagent-base version: $$PRIMEAGENT_BASE_VERSION$(NC)"; \
	\
	echo "$(GREEN)Updating main pyproject.toml...$(NC)"; \
	python -c "import re; fname='pyproject.toml'; txt=open(fname).read(); txt=re.sub(r'^version = \".*\"', 'version = \"$$PRIMEAGENT_VERSION\"', txt, flags=re.MULTILINE); txt=re.sub(r'\"primeagent-base==.*\"', '\"primeagent-base==$$PRIMEAGENT_BASE_VERSION\"', txt); open(fname, 'w').write(txt)"; \
	\
	echo "$(GREEN)Updating primeagent-base pyproject.toml...$(NC)"; \
	python -c "import re; fname='src/backend/base/pyproject.toml'; txt=open(fname).read(); txt=re.sub(r'^version = \".*\"', 'version = \"$$PRIMEAGENT_BASE_VERSION\"', txt, flags=re.MULTILINE); open(fname, 'w').write(txt)"; \
	\
	echo "$(GREEN)Updating frontend package.json...$(NC)"; \
	python -c "import re; fname='src/frontend/package.json'; txt=open(fname).read(); txt=re.sub(r'\"version\": \".*\"', '\"version\": \"$$PRIMEAGENT_VERSION\"', txt); open(fname, 'w').write(txt)"; \
	\
	echo "$(GREEN)Validating version changes...$(NC)"; \
	if ! grep -q "^version = \"$$PRIMEAGENT_VERSION\"" pyproject.toml; then echo "$(RED)? Main pyproject.toml version validation failed$(NC)"; exit 1; fi; \
	if ! grep -q "\"primeagent-base==$$PRIMEAGENT_BASE_VERSION\"" pyproject.toml; then echo "$(RED)? Main pyproject.toml primeagent-base dependency validation failed$(NC)"; exit 1; fi; \
	if ! grep -q "^version = \"$$PRIMEAGENT_BASE_VERSION\"" src/backend/base/pyproject.toml; then echo "$(RED)? Primeagent-base pyproject.toml version validation failed$(NC)"; exit 1; fi; \
	if ! grep -q "\"version\": \"$$PRIMEAGENT_VERSION\"" src/frontend/package.json; then echo "$(RED)? Frontend package.json version validation failed$(NC)"; exit 1; fi; \
	echo "$(GREEN)? All versions updated successfully$(NC)"; \
	\
	echo "$(GREEN)Syncing dependencies in parallel...$(NC)"; \
	uv sync --quiet & \
	(cd src/frontend && pnpm install --silent) & \
	wait; \
	\
	echo "$(GREEN)Validating final state...$(NC)"; \
	CHANGED_FILES=$$(git status --porcelain | wc -l | tr -d ' '); \
	if [ "$$CHANGED_FILES" -lt 5 ]; then \
		echo "$(RED)? Expected at least 5 changed files, but found $$CHANGED_FILES$(NC)"; \
		echo "$(RED)Changed files:$(NC)"; \
		git status --porcelain; \
		exit 1; \
	fi; \
	EXPECTED_FILES="pyproject.toml uv.lock src/backend/base/pyproject.toml src/frontend/package.json src/frontend/pnpm-lock.yaml"; \
	for file in $$EXPECTED_FILES; do \
		if ! git status --porcelain | grep -q "$$file"; then \
			echo "$(RED)? Expected file $$file was not modified$(NC)"; \
			exit 1; \
		fi; \
	done; \
	echo "$(GREEN)? All required files were modified.$(NC)"; \
	\
	echo "$(GREEN)Version update complete!$(NC)"; \
	echo "$(GREEN)Updated files:$(NC)"; \
	echo "  - pyproject.toml: $$PRIMEAGENT_VERSION"; \
	echo "  - src/backend/base/pyproject.toml: $$PRIMEAGENT_BASE_VERSION"; \
	echo "  - src/frontend/package.json: $$PRIMEAGENT_VERSION"; \
	echo "  - uv.lock: dependency lock updated"; \
	echo "  - src/frontend/pnpm-lock.yaml: dependency lock updated"; \
	echo "$(GREEN)Dependencies synced successfully!$(NC)"

publish_base:
	cd src/backend/base && uv publish

publish_primeagent:
	uv publish

publish_base_testpypi:
	# TODO: update this to use the test-pypi repository
	cd src/backend/base && uv publish -r test-pypi

publish_primeagent_testpypi:
	# TODO: update this to use the test-pypi repository
	uv publish -r test-pypi

publish: ## build the frontend static files and package the project and publish it to PyPI
	@echo 'Publishing the project'
ifdef base
	make publish_base
endif

ifdef main
	make publish_primeagent
endif
