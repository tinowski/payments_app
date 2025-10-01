#!/bin/bash

# Robot Framework Test Execution Script for Payments API
# This script provides easy execution of organized Robot Framework tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="results"
LOG_LEVEL="INFO"
BASE_URL="http://localhost:8080"
TEST_TYPE="all"

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --test-type TYPE     Test type to run (smoke|crud|validation|performance|all) [default: all]"
    echo "  -o, --output-dir DIR     Output directory for test results [default: results]"
    echo "  -l, --log-level LEVEL    Log level (DEBUG|INFO|WARN|ERROR) [default: INFO]"
    echo "  -u, --base-url URL       Base URL for the API [default: http://localhost:8080]"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --test-type smoke"
    echo "  $0 --test-type crud --log-level DEBUG"
    echo "  $0 --test-type performance --output-dir perf_results"
    echo "  $0 --base-url http://staging-api.example.com"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--test-type)
            TEST_TYPE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -l|--log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        -u|--base-url)
            BASE_URL="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_message $RED "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate test type
case $TEST_TYPE in
    smoke|crud|validation|performance|all)
        ;;
    *)
        print_message $RED "Invalid test type: $TEST_TYPE"
        show_usage
        exit 1
        ;;
esac

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

print_message $BLUE "=========================================="
print_message $BLUE "Robot Framework Test Execution"
print_message $BLUE "=========================================="
print_message $BLUE "Test Type: $TEST_TYPE"
print_message $BLUE "Output Directory: $OUTPUT_DIR"
print_message $BLUE "Log Level: $LOG_LEVEL"
print_message $BLUE "Base URL: $BASE_URL"
print_message $BLUE "=========================================="

# Check if Robot Framework is installed
if ! command -v robot &> /dev/null; then
    print_message $RED "Robot Framework is not installed. Please install it first:"
    print_message $YELLOW "pip install robotframework"
    exit 1
fi

# Check if API server is running
print_message $YELLOW "Checking if API server is running..."
if curl -s "$BASE_URL/health" > /dev/null 2>&1; then
    print_message $GREEN "API server is running at $BASE_URL"
else
    print_message $RED "API server is not running at $BASE_URL"
    print_message $YELLOW "Please start the Payments API server before running tests"
    exit 1
fi

# Run tests based on test type
case $TEST_TYPE in
    smoke)
        print_message $BLUE "Running smoke tests..."
        robot --outputdir "$OUTPUT_DIR" --loglevel "$LOG_LEVEL" --variable "BASE_URL:$BASE_URL" --include smoke run_simple_tests.robot
        ;;
    crud)
        print_message $BLUE "Running CRUD tests..."
        robot --outputdir "$OUTPUT_DIR" --loglevel "$LOG_LEVEL" --variable "BASE_URL:$BASE_URL" --include crud run_simple_tests.robot
        ;;
    validation)
        print_message $BLUE "Running validation tests..."
        robot --outputdir "$OUTPUT_DIR" --loglevel "$LOG_LEVEL" --variable "BASE_URL:$BASE_URL" --include validation run_simple_tests.robot
        ;;
    performance)
        print_message $BLUE "Running performance tests..."
        robot --outputdir "$OUTPUT_DIR" --loglevel "$LOG_LEVEL" --variable "BASE_URL:$BASE_URL" --include performance run_simple_tests.robot
        ;;
    all)
        print_message $BLUE "Running all tests..."
        robot --outputdir "$OUTPUT_DIR" --loglevel "$LOG_LEVEL" --variable "BASE_URL:$BASE_URL" run_simple_tests.robot
        ;;
esac

# Check test results
if [ $? -eq 0 ]; then
    print_message $GREEN "=========================================="
    print_message $GREEN "All tests passed successfully!"
    print_message $GREEN "Results saved to: $OUTPUT_DIR"
    print_message $GREEN "=========================================="
else
    print_message $RED "=========================================="
    print_message $RED "Some tests failed. Check the results in: $OUTPUT_DIR"
    print_message $RED "=========================================="
    exit 1
fi
