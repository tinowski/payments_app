*** Settings ***
Documentation    Test configuration and constants for Robot Framework tests
Library          Collections

*** Variables ***
# API Configuration
${BASE_URL}                    http://localhost:8080
${GRAPHQL_ENDPOINT}            ${BASE_URL}/query
${HEALTH_ENDPOINT}             ${BASE_URL}/health
${SESSION_NAME}                payments_api
${TEST_TIMEOUT}                30

# Test Data
${VALID_CURRENCIES}            USD    EUR    GBP    JPY    CAD    AUD    CHF    CNY
${VALID_STATUSES}              PENDING    COMPLETED    CANCELLED    FAILED
${TEST_AMOUNTS}                100.00    250.50    999.99    1234.56
${TEST_DESCRIPTIONS}           Test Payment    Robot Framework Test    API Test Payment

# Performance Test Configuration
${MAX_RESPONSE_TIME}           5
${MAX_HEALTH_TIME}             1
${MAX_CRUD_TIME}               10
${MAX_CONCURRENT_TIME}         15
${LOAD_TEST_REQUESTS}          20
${STRESS_TEST_REQUESTS}        100
${MEMORY_TEST_BATCHES}         5
${MEMORY_TEST_REQUESTS}        10

# Test Tags
${SMOKE_TAGS}                  smoke    critical
${REGRESSION_TAGS}             regression    full
${PERFORMANCE_TAGS}            performance    load
${VALIDATION_TAGS}             validation    negative

# Test Data Scenarios
${NORMAL_SCENARIO}             normal
${LARGE_AMOUNT_SCENARIO}       large_amount
${PRECISION_SCENARIO}          precision
${UNICODE_SCENARIO}            unicode
${SPECIAL_CHARS_SCENARIO}      special_chars

# Error Messages
${ERROR_AMOUNT_REQUIRED}       amount must be greater than 0
${ERROR_CURRENCY_REQUIRED}     currency is required
${ERROR_DESCRIPTION_REQUIRED}  description is required
${ERROR_PAYMENT_NOT_FOUND}     payment not found

# Test Suites
${CRUD_TEST_SUITE}             robot_tests/test_suites/payment_crud.robot
${VALIDATION_TEST_SUITE}       robot_tests/test_suites/payment_validation.robot
${PERFORMANCE_TEST_SUITE}      robot_tests/test_suites/performance_tests.robot

# Output Configuration
${OUTPUT_DIR}                  robot_tests/results
${LOG_LEVEL}                   INFO
${LOG_FILE}                    ${OUTPUT_DIR}/test_execution.log
${REPORT_FILE}                 ${OUTPUT_DIR}/report.html
${OUTPUT_FILE}                 ${OUTPUT_DIR}/output.xml

*** Keywords ***
Get Test Configuration
    [Documentation]    Get test configuration for specific test type
    [Arguments]    ${test_type}
    ${config}=    Create Dictionary
    
    Run Keyword If    '${test_type}' == 'smoke'    Set Smoke Test Config    ${config}
    Run Keyword If    '${test_type}' == 'regression'    Set Regression Test Config    ${config}
    Run Keyword If    '${test_type}' == 'performance'    Set Performance Test Config    ${config}
    Run Keyword If    '${test_type}' == 'validation'    Set Validation Test Config    ${config}
    
    RETURN    ${config}

Set Smoke Test Config
    [Documentation]    Set configuration for smoke tests
    [Arguments]    ${config}
    Set To Dictionary    ${config}    timeout    ${TEST_TIMEOUT}
    Set To Dictionary    ${config}    max_response_time    ${MAX_RESPONSE_TIME}
    Set To Dictionary    ${config}    request_count    5
    Set To Dictionary    ${config}    tags    ${SMOKE_TAGS}

Set Regression Test Config
    [Documentation]    Set configuration for regression tests
    [Arguments]    ${config}
    Set To Dictionary    ${config}    timeout    ${TEST_TIMEOUT}
    Set To Dictionary    ${config}    max_response_time    ${MAX_RESPONSE_TIME}
    Set To Dictionary    ${config}    request_count    50
    Set To Dictionary    ${config}    tags    ${REGRESSION_TAGS}

Set Performance Test Config
    [Documentation]    Set configuration for performance tests
    [Arguments]    ${config}
    Set To Dictionary    ${config}    timeout    60
    Set To Dictionary    ${config}    max_response_time    ${MAX_RESPONSE_TIME}
    Set To Dictionary    ${config}    request_count    ${LOAD_TEST_REQUESTS}
    Set To Dictionary    ${config}    concurrent_requests    5
    Set To Dictionary    ${config}    tags    ${PERFORMANCE_TAGS}

Set Validation Test Config
    [Documentation]    Set configuration for validation tests
    [Arguments]    ${config}
    Set To Dictionary    ${config}    timeout    ${TEST_TIMEOUT}
    Set To Dictionary    ${config}    max_response_time    ${MAX_RESPONSE_TIME}
    Set To Dictionary    ${config}    request_count    20
    Set To Dictionary    ${config}    tags    ${VALIDATION_TAGS}

Get Test Data
    [Documentation]    Get test data for specific scenario
    [Arguments]    ${scenario}=${NORMAL_SCENARIO}
    ${data}=    Create Dictionary
    
    Run Keyword If    '${scenario}' == '${NORMAL_SCENARIO}'    Set Normal Test Data    ${data}
    Run Keyword If    '${scenario}' == '${LARGE_AMOUNT_SCENARIO}'    Set Large Amount Test Data    ${data}
    Run Keyword If    '${scenario}' == '${PRECISION_SCENARIO}'    Set Precision Test Data    ${data}
    Run Keyword If    '${scenario}' == '${UNICODE_SCENARIO}'    Set Unicode Test Data    ${data}
    Run Keyword If    '${scenario}' == '${SPECIAL_CHARS_SCENARIO}'    Set SpecialChars Test Data    ${data}
    
    [Return]    ${data}

Set Normal Test Data
    [Documentation]    Set normal test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100.00
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    Test Payment

Set Large Amount Test Data
    [Documentation]    Set large amount test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    999999.99
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    Large Amount Test Payment

Set Precision Test Data
    [Documentation]    Set precision test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    123.456789
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    Precision Test Payment

Set Unicode Test Data
    [Documentation]    Set unicode test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100.00
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    测试支付 🚀 €£¥

Set SpecialChars Test Data
    [Documentation]    Set special characters test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100.00
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    Payment with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?
