#!/bin/bash

echo "🧪 Running Organized Test Suite"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run tests and show results
run_test_suite() {
    local test_type=$1
    local test_path=$2
    local description=$3
    
    echo ""
    echo -e "${BLUE}📊 Running $description...${NC}"
    echo "----------------------------------------"
    
    if go test -v "$test_path"; then
        echo -e "${GREEN}✅ $description passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ $description failed!${NC}"
        return 1
    fi
}

# Function to run tests with coverage
run_test_suite_with_coverage() {
    local test_type=$1
    local test_path=$2
    local description=$3
    
    echo ""
    echo -e "${BLUE}📊 Running $description with coverage...${NC}"
    echo "----------------------------------------"
    
    if go test -v -cover "$test_path"; then
        echo -e "${GREEN}✅ $description passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ $description failed!${NC}"
        return 1
    fi
}

# Track test results
unit_passed=0
integration_passed=0
e2e_passed=0

# Run Unit Tests
echo -e "${YELLOW}🔬 UNIT TESTS${NC}"
echo "============="
run_test_suite "unit" "./tests/unit/..." "Unit Tests"
unit_passed=$?

# Run Integration Tests
echo -e "${YELLOW}🔗 INTEGRATION TESTS${NC}"
echo "===================="
run_test_suite "integration" "./tests/integration/..." "Integration Tests"
integration_passed=$?

# Run E2E Tests
echo -e "${YELLOW}🌐 END-TO-END TESTS${NC}"
echo "====================="
run_test_suite "e2e" "./tests/e2e/..." "E2E Tests"
e2e_passed=$?

# Run Coverage Report
echo ""
echo -e "${YELLOW}📈 COVERAGE REPORT${NC}"
echo "=================="
echo "Generating coverage report for all tests..."
go test -v -cover ./tests/unit/... ./tests/integration/... ./tests/e2e/...
go test -coverprofile=coverage.out ./tests/unit/... ./tests/integration/... ./tests/e2e/...
go tool cover -html=coverage.out -o coverage.html

# Summary
echo ""
echo -e "${YELLOW}📋 TEST SUMMARY${NC}"
echo "==============="
echo -e "Unit Tests:        $([ $unit_passed -eq 0 ] && echo -e "${GREEN}✅ PASSED${NC}" || echo -e "${RED}❌ FAILED${NC}")"
echo -e "Integration Tests: $([ $integration_passed -eq 0 ] && echo -e "${GREEN}✅ PASSED${NC}" || echo -e "${RED}❌ FAILED${NC}")"
echo -e "E2E Tests:         $([ $e2e_passed -eq 0 ] && echo -e "${GREEN}✅ PASSED${NC}" || echo -e "${RED}❌ FAILED${NC}")"

# Overall result
if [ $unit_passed -eq 0 ] && [ $integration_passed -eq 0 ] && [ $e2e_passed -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo "📄 Coverage report generated: coverage.html"
    exit 0
else
    echo ""
    echo -e "${RED}💥 SOME TESTS FAILED!${NC}"
    echo "📄 Coverage report generated: coverage.html"
    exit 1
fi
