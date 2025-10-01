# Robot Framework Test Suite for Payments API

This directory contains a well-organized Robot Framework test suite for the Payments API, designed for easy maintenance, reusability, and scalability.

## Directory Structure

```
robot_tests/
├── config/                    # Test configuration and constants
│   └── test_config.robot     # Centralized test configuration
├── keywords/                  # Reusable keyword libraries
│   ├── api_keywords.robot    # API communication keywords
│   ├── assertion_keywords.robot  # Assertion and verification keywords
│   ├── common_keywords.robot # Common utility keywords
│   ├── performance_keywords.robot  # Performance testing keywords
│   ├── test_data_keywords.robot   # Test data generation keywords
│   └── validation_keywords.robot  # Validation testing keywords
├── setup/                     # Test setup and teardown
│   └── global_setup.robot    # Global test setup
├── test_suites/              # Test suite files
│   ├── payment_crud.robot    # CRUD operations tests
│   ├── payment_validation.robot  # Input validation tests
│   └── performance_tests.robot   # Performance and load tests
├── results/                   # Test execution results (generated)
├── run_tests.robot           # Test suite dispatcher (runs different test suites)
├── run_simple_tests.robot    # Comprehensive test suite (recommended for most use)
└── README.md                 # This file
```

## Key Features

### 1. **Modular Architecture**
- **Keywords**: Organized by functionality (API, assertions, validation, performance)
- **Test Suites**: Focused on specific test areas (CRUD, validation, performance)
- **Configuration**: Centralized test configuration and constants

### 2. **Reusability**
- Common keywords can be used across multiple test suites
- Test data generation for various scenarios
- Centralized assertion keywords for consistent validation

### 3. **Maintainability**
- Clear separation of concerns
- Consistent naming conventions
- Comprehensive documentation
- Easy to add new tests or modify existing ones

### 4. **Scalability**
- Data-driven testing capabilities
- Performance testing with configurable parameters
- Support for different test scenarios and environments

## Keyword Libraries

### `api_keywords.robot`
Core API communication keywords:
- `Create Payment` - Create new payments
- `Get Payment` - Retrieve payments by ID
- `Update Payment` - Update existing payments
- `Delete Payment` - Delete payments
- `Health Check` - Verify API health
- `Send GraphQL Request` - Generic GraphQL request handler

### `assertion_keywords.robot`
Comprehensive assertion keywords:
- `Assert Payment Created Successfully` - Validate payment creation
- `Assert Payment Updated Successfully` - Validate payment updates
- `Assert Payment Deleted Successfully` - Validate payment deletion
- `Assert Validation Error` - Validate error responses
- `Assert Response Time` - Validate performance metrics

### `common_keywords.robot`
Common utility keywords:
- `Extract Payment ID` - Extract payment ID from responses
- `Verify Payment Data` - Verify payment data matches expectations
- `Measure Response Time` - Measure operation response times
- `Test Special Characters` - Test special character handling
- `Test Unicode Characters` - Test unicode character handling

### `validation_keywords.robot`
Input validation testing keywords:
- `Test Invalid Payment Creation` - Test invalid payment creation
- `Test Invalid Payment Update` - Test invalid payment updates
- `Test Non-Existent Payment Operations` - Test operations on non-existent payments
- `Test Whitespace Validation` - Test whitespace input validation
- `Test Amount Validation` - Test amount field validation
- `Test Currency Validation` - Test currency field validation

### `performance_keywords.robot`
Performance and load testing keywords:
- `Test Health Check Performance` - Test health check response time
- `Test Multiple Payment Creation Performance` - Test bulk payment creation
- `Test CRUD Performance` - Test complete CRUD cycle performance
- `Test Concurrent Payment Creation` - Test concurrent request handling
- `Test Memory Usage Stability` - Test memory stability under load
- `Test Response Time Under Load` - Test response times under various loads

### `test_data_keywords.robot`
Test data generation and management:
- `Generate Test Payment Data` - Generate test data for various scenarios
- `Generate Invalid Payment Data` - Generate invalid test data
- `Generate Multiple Test Payments` - Generate multiple test payments
- `Generate Performance Test Data` - Generate performance test data

## Test Suites

### `payment_crud.robot`
Comprehensive CRUD operation tests:
- Health check verification
- Payment creation with various currencies and amounts
- Payment retrieval and validation
- Payment updates (amount, status, description)
- Payment deletion and verification
- Complete payment lifecycle testing

### `payment_validation.robot`
Input validation and error handling tests:
- Invalid amount validation (negative, zero)
- Empty field validation (currency, description)
- Whitespace validation
- Non-existent payment operations
- Special character and unicode handling
- Long description handling

### `performance_tests.robot`
Performance and load testing:
- API response time testing
- Health check performance
- Multiple payment creation performance
- CRUD operation performance
- Concurrent request handling
- Large amount and precision handling
- Memory usage stability testing

## Configuration

### `test_config.robot`
Centralized configuration including:
- API endpoints and timeouts
- Test data constants
- Performance thresholds
- Test tags and categories
- Error message constants
- Output configuration

## Running Tests

### Prerequisites
1. Install Robot Framework: `pip install robotframework`
2. Install required libraries: `pip install -r requirements.txt`
3. Start the Payments API server

### Basic Test Execution
```bash
# RECOMMENDED: Run comprehensive test suite
robot robot_tests/run_simple_tests.robot

# Run test dispatcher (runs different test suites)
robot robot_tests/run_tests.robot

# Run specific test suites directly
robot robot_tests/test_suites/payment_crud.robot
robot robot_tests/test_suites/payment_validation.robot
robot robot_tests/test_suites/performance_tests.robot

# Run tests with specific tags
robot --include smoke robot_tests/run_simple_tests.robot
robot --include performance robot_tests/run_simple_tests.robot
robot --include validation robot_tests/run_simple_tests.robot
```

### Advanced Test Execution
```bash
# Run with custom output directory
robot --outputdir robot_tests/results robot_tests/run_simple_tests.robot

# Run with specific log level
robot --loglevel DEBUG robot_tests/run_simple_tests.robot

# Run with custom variables
robot --variable BASE_URL:http://localhost:8080 robot_tests/run_simple_tests.robot

# Run in parallel (if using pabot)
pabot --processes 4 robot_tests/run_simple_tests.robot

# Use the execution script
./robot_tests/run_tests.sh --test-type smoke
./robot_tests/run_tests.sh --test-type all
```

## Test Data Management

The test suite supports various test data scenarios:
- **Normal**: Standard test data
- **Large Amount**: Large payment amounts
- **Precision**: High precision decimal amounts
- **Unicode**: Unicode character descriptions
- **Special Chars**: Special character descriptions

## Performance Testing

The performance testing suite includes:
- Response time validation
- Load testing with configurable request counts
- Stress testing with high concurrent requests
- Memory stability testing
- API health monitoring under load

## Best Practices

1. **Use Descriptive Test Names**: Test names should clearly describe what is being tested
2. **Group Related Tests**: Use tags to group related tests
3. **Use Data-Driven Testing**: Leverage test data keywords for multiple scenarios
4. **Maintain Test Independence**: Each test should be independent and not rely on other tests
5. **Clean Up Test Data**: Always clean up test data after test execution
6. **Use Assertions Consistently**: Use assertion keywords for consistent validation
7. **Document Test Purpose**: Include clear documentation for each test case

## Adding New Tests

1. **New Test Cases**: Add to appropriate test suite file
2. **New Keywords**: Add to appropriate keyword library
3. **New Test Data**: Add to test data keywords
4. **New Assertions**: Add to assertion keywords
5. **New Configuration**: Add to test configuration file

## Troubleshooting

### Common Issues
1. **Server Not Ready**: Ensure the Payments API server is running
2. **Test Failures**: Check logs for detailed error messages
3. **Performance Issues**: Adjust performance thresholds in configuration
4. **Data Cleanup**: Ensure test data is properly cleaned up

### Debug Mode
Run tests in debug mode for detailed logging:
```bash
robot --loglevel DEBUG robot_tests/run_organized_tests.robot
```

## Contributing

When adding new tests or keywords:
1. Follow the existing naming conventions
2. Add appropriate documentation
3. Include both positive and negative test cases
4. Ensure tests are independent and can run in any order
5. Update this README if adding new functionality
