#!/bin/bash

# Robot Framework Test Runner Script
# Usage: ./run_robot_framework_tests.sh [test_type] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE="all"
VERBOSE=false
QUIET=false
CLEAN=false
INSTALL=false

# Function to show usage
show_usage() {
    echo "Robot Framework Test Runner"
    echo "=========================="
    echo ""
    echo "Usage: $0 [OPTIONS] [TEST_TYPE]"
    echo ""
    echo "Test Types:"
    echo "  all          Run all tests (default)"
    echo "  smoke        Run smoke tests only"
    echo "  crud         Run CRUD operation tests"
    echo "  validation   Run validation tests"
    echo "  performance  Run performance tests"
    echo ""
    echo "Options:"
    echo "  -v, --verbose    Verbose output"
    echo "  -q, --quiet      Quiet output"
    echo "  -c, --clean      Clean results before running"
    echo "  -i, --install    Install dependencies before running"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 smoke              # Run smoke tests only"
    echo "  $0 -v crud            # Run CRUD tests with verbose output"
    echo "  $0 -c -i all          # Clean, install, and run all tests"
}

# Function to check if server is running
check_server() {
    echo -e "${BLUE}Checking if server is running...${NC}"
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server is running${NC}"
        return 0
    else
        echo -e "${RED}❌ Server is not running${NC}"
        echo -e "${YELLOW}Please start the server first:${NC}"
        echo "  make run"
        echo "  # or, if the binary is in the current directory:"
        echo "  ./payments_app"
        return 1
    fi
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Installing Robot Framework dependencies...${NC}"
    if command -v pip3 &> /dev/null; then
        pip3 install -r requirements.txt
    elif command -v pip &> /dev/null; then
        pip install -r requirements.txt
    else
        echo -e "${RED}❌ pip not found. Please install Python and pip first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Dependencies installed${NC}"
}

# Function to clean results
clean_results() {
    echo -e "${BLUE}Cleaning previous test results...${NC}"
    rm -rf robot_reports
    rm -rf robot_results
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Function to create directories
setup_directories() {
    echo -e "${BLUE}Setting up test directories...${NC}"
    mkdir -p robot_reports
    mkdir -p robot_results
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Function to run tests
run_tests() {
    local test_type=$1
    local robot_options="--outputdir robot_results --log robot_reports/log.html --report robot_reports/report.html"
    
    if [ "$VERBOSE" = true ]; then
        robot_options="$robot_options --loglevel DEBUG"
    elif [ "$QUIET" = true ]; then
        robot_options="$robot_options --loglevel WARN"
    fi
    
    echo -e "${BLUE}Running $test_type tests...${NC}"
    
    # Centralized mapping of test types to suite paths
    case $test_type in
        "all")
            robot $robot_options robot_tests/run_tests.robot
            ;;
        "smoke")
            robot $robot_options --include smoke robot_tests/run_tests.robot
            ;;
        "crud")
            robot $robot_options robot_tests/test_suites/payment_crud.robot
            ;;
        "validation")
            robot $robot_options robot_tests/test_suites/payment_validation.robot
            ;;
        "performance")
            robot $robot_options robot_tests/test_suites/performance_tests.robot
            ;;
        *)
            echo -e "${RED}❌ Unknown test type: $test_type${NC}"
            show_usage
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Tests completed!${NC}"
    echo -e "${YELLOW}📊 Results available at: robot_reports/report.html${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -i|--install)
            INSTALL=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        all|smoke|crud|validation|performance)
            TEST_TYPE=$1
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
echo -e "${GREEN}🤖 Robot Framework Test Runner${NC}"
echo "================================"

# Install dependencies if requested
if [ "$INSTALL" = true ]; then
    install_dependencies
fi

# Clean results if requested
if [ "$CLEAN" = true ]; then
    clean_results
fi

# Setup directories
setup_directories

# Check if server is running
if ! check_server; then
    exit 1
fi

# Run tests
run_tests $TEST_TYPE

echo -e "${GREEN}🎉 All done!${NC}"
