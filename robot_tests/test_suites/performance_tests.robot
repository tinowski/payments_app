*** Settings ***
Documentation    Performance and load testing for Payments API
Resource        ../keywords/api_keywords.robot
Resource        ../keywords/performance_keywords.robot
Resource        ../keywords/common_keywords.robot
Test Setup      Start API Session
Test Teardown   Delete All Sessions

*** Variables ***
${CONCURRENT_USERS}    5
${REQUESTS_PER_USER}   10

*** Test Cases ***
Test API Response Time
    [Documentation]    Test API response time for basic operations
    ${start_time}=    Get Current Date    result_format=epoch
    ${response}=    Create Payment    100.00    USD    Performance test payment
    ${end_time}=    Get Current Date    result_format=epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    Should Be True    ${response_time} < 5    Response time should be less than 5 seconds, got ${response_time}s

Test Health Check Performance
    [Documentation]    Test health check endpoint performance
    Test Health Check Performance

Test Multiple Payment Creation
    [Documentation]    Test creating multiple payments in sequence
    Test Multiple Payment Creation Performance    20

Test Payment CRUD Performance
    [Documentation]    Test complete CRUD operations performance
    Test CRUD Performance

Test Concurrent Payment Creation
    [Documentation]    Test creating payments concurrently (simulated)
    Test Concurrent Payment Creation    10

Test Large Amount Handling
    [Documentation]    Test handling of large payment amounts
    Test Large Amount Handling

Test High Precision Amounts
    [Documentation]    Test handling of high precision decimal amounts
    Test High Precision Amounts

Test Memory Usage Stability
    [Documentation]    Test that API remains stable under repeated requests
    Test Memory Usage Stability    5    10
