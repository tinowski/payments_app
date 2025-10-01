*** Settings ***
Documentation    Global setup and teardown for all Robot Framework tests
Library          RequestsLibrary
Library          Collections
Library          JSONLibrary
Library          String
Library          DateTime

*** Variables ***
${BASE_URL}      http://localhost:8080
${GRAPHQL_ENDPOINT}    ${BASE_URL}/query
${HEALTH_ENDPOINT}     ${BASE_URL}/health
${SESSION_NAME}  payments_api
${TEST_TIMEOUT}  30

# Test data storage
${CREATED_PAYMENTS}    @{EMPTY}
${TEST_START_TIME}     ${EMPTY}

*** Keywords ***
Global Suite Setup
    [Documentation]    Setup for entire test suite
    Log    Starting Payments API Test Suite
    Set Global Variable    ${TEST_START_TIME}    ${EMPTY}
    ${start_time}=    Get Current Date    result_format=epoch
    Set Global Variable    ${TEST_START_TIME}    ${start_time}
    
    # Wait for server to be ready
    Wait For Server Ready
    Log    Server is ready, starting tests

Global Suite Teardown
    [Documentation]    Cleanup for entire test suite
    Log    Cleaning up test suite
    
    # Clean up any created test data
    Clean Up Test Data
    
    # Calculate total test time
    ${end_time}=    Get Current Date    result_format=epoch
    ${total_time}=    Evaluate    ${end_time} - ${TEST_START_TIME}
    Log    Total test suite execution time: ${total_time} seconds
    
    # Close all sessions
    Delete All Sessions
    Log    Test suite cleanup completed

Test Case Setup
    [Documentation]    Setup for individual test cases
    Log    Starting test case: ${TEST_NAME}
    
    # Ensure we have a fresh session
    Create Session    ${SESSION_NAME}    ${BASE_URL}
    Set Headers    ${SESSION_NAME}    Content-Type=application/json
    
    # Verify server is still responsive
    Health Check

Test Case Teardown
    [Documentation]    Cleanup for individual test cases
    Log    Completing test case: ${TEST_NAME}
    
    # Store any created payment IDs for cleanup
    Run Keyword If    '${TEST_STATUS}' == 'PASS'    Store Created Payment IDs
    
    # Close session
    Delete Session    ${SESSION_NAME}

Wait For Server Ready
    [Documentation]    Wait for server to be ready with timeout
    [Arguments]    ${timeout}=${TEST_TIMEOUT}
    
    Log    Waiting for server to be ready (timeout: ${timeout}s)
    FOR    ${i}    IN RANGE    ${timeout}
        ${response}=    Run Keyword And Return Status    Health Check
        Exit For Loop If    ${response}
        Sleep    1s
    END
    
    Run Keyword If    not ${response}    Fail    Server did not start within ${timeout} seconds
    Log    Server is ready

Health Check
    [Documentation]    Verify API health endpoint
    ${response}=    GET On Session    ${SESSION_NAME}    /health
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    OK

Store Created Payment IDs
    [Documentation]    Store payment IDs for cleanup
    # This will be implemented by individual test cases
    # that need to track created payments
    Log    Storing created payment IDs for cleanup

Clean Up Test Data
    [Documentation]    Clean up any test data created during tests
    Log    Cleaning up test data
    
    # Clean up created payments
    FOR    ${payment_id}    IN    @{CREATED_PAYMENTS}
        Run Keyword And Ignore Error    Delete Test Payment    ${payment_id}
    END
    
    # Clear the list
    Set Global Variable    ${CREATED_PAYMENTS}    @{EMPTY}
    Log    Test data cleanup completed

Delete Test Payment
    [Documentation]    Delete a specific test payment
    [Arguments]    ${payment_id}
    
    ${query}=    Set Variable    mutation { deletePayment(id: "${payment_id}") }
    ${payload}=    Create Dictionary    query=${query}
    
    ${response}=    POST On Session    ${SESSION_NAME}    /query    json=${payload}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    Log    Deleted test payment: ${payment_id}

Add Payment To Cleanup List
    [Documentation]    Add a payment ID to the cleanup list
    [Arguments]    ${payment_id}
    
    Append To List    ${CREATED_PAYMENTS}    ${payment_id}
    Log    Added payment ${payment_id} to cleanup list
