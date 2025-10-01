# Robot Framework Testing Makefile
# Usage: make robot-test, make robot-smoke, make robot-performance, etc.

# Python and Robot Framework settings
PYTHON := python3
ROBOT := robot
PIP := pip3

# Test directories
ROBOT_TESTS_DIR := robot_tests
REPORTS_DIR := robot_reports
RESULTS_DIR := robot_results

# Test suites
CRUD_SUITE := $(ROBOT_TESTS_DIR)/test_suites/payment_crud.robot
VALIDATION_SUITE := $(ROBOT_TESTS_DIR)/test_suites/payment_validation.robot
PERFORMANCE_SUITE := $(ROBOT_TESTS_DIR)/test_suites/performance_tests.robot
MAIN_SUITE := $(ROBOT_TESTS_DIR)/run_tests.robot

# Robot Framework options
ROBOT_OPTIONS := --outputdir $(RESULTS_DIR) --log $(REPORTS_DIR)/log.html --report $(REPORTS_DIR)/report.html
ROBOT_OPTIONS_VERBOSE := $(ROBOT_OPTIONS) --loglevel DEBUG
ROBOT_OPTIONS_QUIET := $(ROBOT_OPTIONS) --loglevel WARN

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help robot-setup robot-test robot-smoke robot-crud robot-validation robot-performance robot-clean robot-install robot-verbose robot-quiet

help: ## Show this help message
	@echo "$(YELLOW)Robot Framework Testing Commands$(NC)"
	@echo "=================================="
	@echo ""
	@echo "$(GREEN)Setup Commands:$(NC)"
	@echo "  robot-install    Install Robot Framework and dependencies"
	@echo "  robot-setup      Create necessary directories"
	@echo ""
	@echo "$(GREEN)Test Commands:$(NC)"
	@echo "  robot-test       Run all Robot Framework tests"
	@echo "  robot-smoke      Run smoke tests only"
	@echo "  robot-crud       Run CRUD operation tests"
	@echo "  robot-validation Run validation tests"
	@echo "  robot-performance Run performance tests"
	@echo ""
	@echo "$(GREEN)Output Options:$(NC)"
	@echo "  robot-verbose    Run tests with verbose output"
	@echo "  robot-quiet      Run tests with quiet output"
	@echo ""
	@echo "$(GREEN)Cleanup:$(NC)"
	@echo "  robot-clean      Clean test results and reports"
	@echo ""

robot-install: ## Install Robot Framework and dependencies
	@echo "$(YELLOW)Installing Robot Framework and dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Installation complete!$(NC)"

robot-setup: ## Create necessary directories
	@echo "$(YELLOW)Setting up Robot Framework directories...$(NC)"
	mkdir -p $(REPORTS_DIR)
	mkdir -p $(RESULTS_DIR)
	@echo "$(GREEN)Setup complete!$(NC)"

robot-test: robot-setup ## Run all Robot Framework tests
	@echo "$(YELLOW)Running all Robot Framework tests...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS) $(MAIN_SUITE)
	@echo "$(GREEN)All tests completed! Check $(REPORTS_DIR)/report.html for results.$(NC)"

robot-smoke: robot-setup ## Run smoke tests only
	@echo "$(YELLOW)Running smoke tests...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS) --include smoke $(MAIN_SUITE)
	@echo "$(GREEN)Smoke tests completed!$(NC)"

robot-crud: robot-setup ## Run CRUD operation tests
	@echo "$(YELLOW)Running CRUD operation tests...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS) $(CRUD_SUITE)
	@echo "$(GREEN)CRUD tests completed!$(NC)"

robot-validation: robot-setup ## Run validation tests
	@echo "$(YELLOW)Running validation tests...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS) $(VALIDATION_SUITE)
	@echo "$(GREEN)Validation tests completed!$(NC)"

robot-performance: robot-setup ## Run performance tests
	@echo "$(YELLOW)Running performance tests...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS) $(PERFORMANCE_SUITE)
	@echo "$(GREEN)Performance tests completed!$(NC)"

robot-verbose: robot-setup ## Run tests with verbose output
	@echo "$(YELLOW)Running tests with verbose output...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS_VERBOSE) $(MAIN_SUITE)
	@echo "$(GREEN)Verbose tests completed!$(NC)"

robot-quiet: robot-setup ## Run tests with quiet output
	@echo "$(YELLOW)Running tests with quiet output...$(NC)"
	$(ROBOT) $(ROBOT_OPTIONS_QUIET) $(MAIN_SUITE)
	@echo "$(GREEN)Quiet tests completed!$(NC)"

robot-clean: ## Clean test results and reports
	@echo "$(YELLOW)Cleaning Robot Framework results...$(NC)"
	rm -rf $(REPORTS_DIR)
	rm -rf $(RESULTS_DIR)
	@echo "$(GREEN)Cleanup complete!$(NC)"

# Integration with main Makefile
test-robot: robot-test ## Alias for robot-test
test-robot-smoke: robot-smoke ## Alias for robot-smoke
test-robot-crud: robot-crud ## Alias for robot-crud
test-robot-validation: robot-validation ## Alias for robot-validation
test-robot-performance: robot-performance ## Alias for robot-performance
