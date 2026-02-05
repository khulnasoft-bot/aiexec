######################
# LOAD TESTING TARGETS
######################

# Default values for locust configuration
locust_users ?= 10
locust_spawn_rate ?= 1
locust_host ?= http://localhost:7860
locust_headless ?= true
locust_time ?= 300s
locust_api_key ?= your-api-key
locust_flow_id ?= your-flow-id
locust_file ?= src/backend/tests/locust/locustfile.py
locust_min_wait ?= 2000
locust_max_wait ?= 5000
locust_request_timeout ?= 30.0

locust: ## run locust load tests
	@if [ ! -f "$(locust_file)" ]; then \
		echo "$(RED)Error: Locustfile not found at $(locust_file)$(NC)"; \
		exit 1; \
	fi
	@echo "Starting Locust with $(locust_users) users, spawn rate of $(locust_spawn_rate)"
	@echo "Testing host: $(locust_host)"
	@echo "Using locustfile: $(locust_file)"
	@export API_KEY=$(locust_api_key) && \
	export FLOW_ID=$(locust_flow_id) && \
	export PRIMEAGENT_HOST=$(locust_host) && \
	export MIN_WAIT=$(locust_min_wait) && \
	export MAX_WAIT=$(locust_max_wait) && \
	export REQUEST_TIMEOUT=$(locust_request_timeout) && \
	cd $$(dirname "$(locust_file)") && \
	if [ "$(locust_headless)" = "true" ]; then \
		uv run locust \
			--headless \
			-u $(locust_users) \
			-r $(locust_spawn_rate) \
			--run-time $(locust_time) \
			--host $(locust_host) \
			-f $$(basename "$(locust_file)"); \
	else \
		uv run locust \
			-u $(locust_users) \
			-r $(locust_spawn_rate) \
			--host $(locust_host) \
			-f $$(basename "$(locust_file)"); \
	fi

load_test_host ?= http://127.0.0.1:8000
load_test_flow_id ?= 5523731d-5ef3-56de-b4ef-59b0a224fdbc
load_test_api_key ?= test
html ?= false

load_test_ramp100: ## Run 100-user ramp load test (3min, 0->100 users @ 5/s)
	@echo "$(YELLOW)Running 100-user ramp load test (3 minutes)$(NC)"
	@export FLOW_ID=$(load_test_flow_id) && \
	export API_KEY=$(load_test_api_key) && \
	export REQUEST_TIMEOUT=10 && \
	cd src/backend/tests/locust && \
	if [ "$(html)" = "true" ]; then \
		echo "$(GREEN)Generating HTML report: ramp100_test.html$(NC)"; \
		uv run locust -f locustfile_complex_serve.py --host $(load_test_host) --headless --html ramp100_test.html; \
	else \
		uv run locust -f locustfile_complex_serve.py --host $(load_test_host) --headless; \
	fi

load_test_cliff: ## Find performance cliff with step ramp (5->50 users, 30s steps)
	@echo "$(YELLOW)Running step ramp to find performance cliff$(NC)"
	@export FLOW_ID=$(load_test_flow_id) && \
	export API_KEY=$(load_test_api_key) && \
	export REQUEST_TIMEOUT=10 && \
	cd src/backend/tests/locust && \
	if [ "$(html)" = "true" ]; then \
		echo "$(GREEN)Generating HTML report: cliff_test.html$(NC)"; \
		uv run locust -f wfx_step_ramp.py --host $(load_test_host) --headless --html cliff_test.html; \
	else \
		uv run locust -f wfx_step_ramp.py --host $(load_test_host) --headless; \
	fi

load_test_wfx_quick: ## Quick WFX load test (30 users, 60s)
	@echo "$(YELLOW)Running quick 30-user load test (60 seconds)$(NC)"
	@export FLOW_ID=$(load_test_flow_id) && \
	export API_KEY=$(load_test_api_key) && \
	export REQUEST_TIMEOUT=10 && \
	cd src/backend/tests/locust && \
	if [ "$(html)" = "true" ]; then \
		echo "$(GREEN)Generating HTML report: quick_test.html$(NC)"; \
		uv run locust -f wfx_serve_locustfile.py --host $(load_test_host) --headless -u 30 -r 5 -t 60s --html quick_test.html; \
	else \
		uv run locust -f wfx_serve_locustfile.py --host $(load_test_host) --headless -u 30 -r 5 -t 60s; \
	fi

load_test_setup: ## Set up load test environment with starter project flows
	@echo "$(YELLOW)Setting up Primeagent load test environment$(NC)"
	@cd src/backend/tests/locust && uv run python primeagent_setup_test.py --interactive

load_test_setup_basic: ## Set up load test environment with Basic Prompting flow
	@echo "$(YELLOW)Setting up load test environment with Basic Prompting flow$(NC)"
	@cd src/backend/tests/locust && uv run python primeagent_setup_test.py --flow "Basic Prompting" --save-credentials load_test_creds.json

load_test_list_flows: ## List available starter project flows
	@echo "$(YELLOW)Listing available starter project flows$(NC)"
	@cd src/backend/tests/locust && uv run python primeagent_setup_test.py --list-flows

load_test_run: ## Run load test (automatically sets up if needed)
	@echo "$(YELLOW)Running load test with enhanced error logging$(NC)"
	@if [ ! -f "src/backend/tests/locust/load_test_creds.json" ]; then \
		echo "$(BLUE)No credentials found. Running automatic setup...$(NC)"; \
		if [ -z "$(FLOW_NAME)" ]; then \
			echo "$(CYAN)Available flows:$(NC)"; \
			cd src/backend/tests/locust && uv run python primeagent_setup_test.py --list-flows; \
			echo "$(RED)Please specify a flow: make load_test_run FLOW_NAME=\"Basic Prompting\"$(NC)"; \
			exit 1; \
		else \
			echo "$(BLUE)Setting up with flow: $(FLOW_NAME)$(NC)"; \
			cd src/backend/tests/locust && uv run python primeagent_setup_test.py --flow "$(FLOW_NAME)" --save-credentials load_test_creds.json; \
		fi \
	fi
	@cd src/backend/tests/locust && \
	export API_KEY=$$(python -c "import json; print(json.load(open('load_test_creds.json'))['api_key'])") && \
	export FLOW_ID=$$(python -c "import json; print(json.load(open('load_test_creds.json'))['flow_id'])") && \
	uv run python primeagent_run_load_test.py --headless --users 20 --duration 120 --no-start-primeagent --html load_test_report.html --csv load_test_results

load_test_primeagent_quick: ## Quick Primeagent load test (10 users, 30s)
	@echo "$(YELLOW)Running quick Primeagent load test with HTML report$(NC)"
	@if [ ! -f "src/backend/tests/locust/load_test_creds.json" ]; then \
		echo "$(BLUE)No credentials found. Running automatic setup...$(NC)"; \
		if [ -z "$(FLOW_NAME)" ]; then \
			echo "$(CYAN)Available flows:$(NC)"; \
			cd src/backend/tests/locust && uv run python primeagent_setup_test.py --list-flows; \
			echo "$(RED)Please specify a flow: make load_test_primeagent_quick FLOW_NAME=\"Basic Prompting\"$(NC)"; \
			exit 1; \
		else \
			echo "$(BLUE)Setting up with flow: $(FLOW_NAME)$(NC)"; \
			cd src/backend/tests/locust && uv run python primeagent_setup_test.py --flow "$(FLOW_NAME)" --save-credentials load_test_creds.json; \
		fi \
	fi
	@cd src/backend/tests/locust && \
	export API_KEY=$$(python -c "import json; print(json.load(open('load_test_creds.json'))['api_key'])") && \
	export FLOW_ID=$$(python -c "import json; print(json.load(open('load_test_creds.json'))['flow_id'])") && \
	uv run python primeagent_run_load_test.py --headless --users 10 --duration 30 --no-start-primeagent --html quick_test_report.html

load_test_stress: ## Stress test (100 users, 5 minutes)
	@echo "$(YELLOW)Running stress test with comprehensive reporting$(NC)"
	@if [ ! -f "src/backend/tests/locust/load_test_creds.json" ]; then \
		echo "$(BLUE)No credentials found. Running automatic setup...$(NC)"; \
		if [ -z "$(FLOW_NAME)" ]; then \
			echo "$(CYAN)Available flows:$(NC)"; \
			cd src/backend/tests/locust && uv run python primeagent_setup_test.py --list-flows; \
			echo "$(RED)Please specify a flow: make load_test_stress FLOW_NAME=\"Basic Prompting\"$(NC)"; \
			exit 1; \
		else \
			echo "$(BLUE)Setting up with flow: $(FLOW_NAME)$(NC)"; \
			cd src/backend/tests/locust && uv run python primeagent_setup_test.py --flow "$(FLOW_NAME)" --save-credentials load_test_creds.json; \
		fi \
	fi
	@cd src/backend/tests/locust && \
	export API_KEY=$$(python -c "import json; print(json.load(open('load_test_creds.json'))['api_key'])") && \
	export FLOW_ID=$$(python -c "import json; print(json.load(open('load_test_creds.json'))['flow_id'])") && \
	uv run python primeagent_run_load_test.py --headless --users 100 --spawn-rate 5 --duration 300 --no-start-primeagent --html stress_test_report.html --csv stress_test_results --shape ramp100

load_test_example: ## Run complete example workflow (setup + test + reports)
	@echo "$(YELLOW)Running complete load test example workflow$(NC)"
	@cd src/backend/tests/locust && uv run python primeagent_example_workflow.py --auto

load_test_clean: ## Clean up load test files and credentials
	@echo "$(YELLOW)Cleaning up load test files$(NC)"
	@cd src/backend/tests/locust && rm -f *.json *.html *.csv *.log
	@echo "$(GREEN)Load test files cleaned$(NC)"

load_test_remote_setup: ## Set up load test for remote instance
	@if [ -z "$(PRIMEAGENT_HOST)" ]; then \
		echo "$(RED)Error: PRIMEAGENT_HOST environment variable required$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Setting up load test for remote instance: $(PRIMEAGENT_HOST)$(NC)"
	@cd src/backend/tests/locust && uv run python primeagent_setup_test.py --host $(PRIMEAGENT_HOST) --flow "Basic Prompting" --save-credentials remote_test_creds.json

load_test_remote_run: ## Run load test against remote instance
	@if [ -z "$(PRIMEAGENT_HOST)" ]; then \
		echo "$(RED)Error: PRIMEAGENT_HOST environment variable required$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "src/backend/tests/locust/remote_test_creds.json" ]; then \
		echo "$(RED)Error: No remote credentials found. Run 'make load_test_remote_setup' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Running load test against remote instance: $(PRIMEAGENT_HOST)$(NC)"
	@cd src/backend/tests/locust && \
	export API_KEY=$$(python -c "import json; print(json.load(open('remote_test_creds.json'))['api_key'])") && \
	export FLOW_ID=$$(python -c "import json; print(json.load(open('remote_test_creds.json'))['flow_id'])") && \
	uv run python primeagent_run_load_test.py --host $(PRIMEAGENT_HOST) --no-start-primeagent --headless --users 10 --spawn-rate 1 --duration 120 --html remote_test_report.html

load_test_help: ## Show detailed load testing help
	@echo "$(GREEN)Primeagent Enhanced Load Testing System$(NC)"
	@echo ""
	@echo "$(YELLOW)Quick Start (Local):$(NC)"
	@echo "  1. make load_test_setup_basic    # Set up with Basic Prompting flow"
	@echo "  2. make load_test_primeagent_quick # Run quick Primeagent test"
	@echo "  3. Open quick_test_report.html  # View results"
	@echo ""
	@echo "$(YELLOW)Remote Testing:$(NC)"
	@echo "  1. export PRIMEAGENT_HOST=https://your-instance.com"
	@echo "  2. make load_test_remote_setup   # Set up for remote testing"
	@echo "  3. make load_test_remote_run     # Run test against remote instance"
	@echo ""
	@echo "$(YELLOW)Available Commands:$(NC)"
	@echo "  load_test_setup        - Interactive flow selection setup"
	@echo "  load_test_setup_basic  - Quick setup with Basic Prompting"
	@echo "  load_test_list_flows   - List available starter flows"
	@echo "  load_test_run          - Standard load test (25 users, 2 min)"
	@echo "  load_test_primeagent_quick - Quick Primeagent test (10 users, 30s)"
	@echo "  load_test_quick        - Quick complex serve test (30 users, 60s)"
	@echo "  load_test_stress       - Stress test (100 users, 5 min)"
	@echo "  load_test_example      - Complete example workflow"
	@echo "  load_test_clean        - Clean up generated files"
