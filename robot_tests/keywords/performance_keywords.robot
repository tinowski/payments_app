*** Settings ***
Documentation    Performance testing keywords for Robot Framework tests
Resource        ../setup/global_setup.robot
Resource        api_keywords.robot
Resource        common_keywords.robot
Library         Collections
Library         JSONLibrary
Library         DateTime

*** Variables ***
${MAX_RESPONSE_TIME}    5
${MAX_HEALTH_TIME}      1
${MAX_CRUD_TIME}        10
${MAX_CONCURRENT_TIME}  15

*** Keywords ***
Test Health Check Performance
    [Documentation]    Test health check endpoint performance
    ${start_time}=    Get Current Date    result_format=epoch
    
    api_keywords.Health Check
    
    ${end_time}=    Get Current Date    result_format=epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    
    Log    Health check took ${response_time} seconds
    Should Be True    ${response_time} < ${MAX_HEALTH_TIME}    Health check should be very fast, got ${response_time}s

Test Multiple Payment Creation Performance
    [Documentation]    Test creating multiple payments performance
    [Arguments]    ${count}=20
    
    ${start_time}=    Get Current Date    result_format=epoch
    
    FOR    ${i}    IN RANGE    ${count}
        ${amount}=    Evaluate    100 + ${i}
        ${response}=    Create Payment    ${amount}    USD    Performance test payment ${i}
        Verify Payment Data    ${response}    ${amount}    USD    Performance test payment ${i}
    END
    
    ${end_time}=    Get Current Date    result_format=epoch
    ${total_time}=    Evaluate    ${end_time} - ${start_time}
    ${avg_time}=    Evaluate    ${total_time} / ${count}
    
    Log    Created ${count} payments in ${total_time}s (avg: ${avg_time}s per payment)
    Should Be True    ${avg_time} < 2    Average response time should be less than 2 seconds

Test CRUD Performance
    [Documentation]    Test complete CRUD operations performance
    ${start_time}=    Get Current Date    result_format=epoch
    
    # Create
    ${create_response}=    Create Payment    100.00    USD    CRUD performance test
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    # Read
    ${get_response}=    Get Payment    ${payment_id}
    Should Not Be Equal    ${get_response['data']['payment']}    ${None}
    
    # Update
    ${update_response}=    Update Payment    ${payment_id}    amount=200.00    status=COMPLETED
    Should Be Equal As Numbers    ${update_response['data']['updatePayment']['amount']}    200.00
    
    # Delete
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}
    
    ${end_time}=    Get Current Date    result_format=epoch
    ${total_time}=    Evaluate    ${end_time} - ${start_time}
    
    Log    Complete CRUD cycle took ${total_time}s
    Should Be True    ${total_time} < ${MAX_CRUD_TIME}    Complete CRUD cycle should take less than ${MAX_CRUD_TIME} seconds

Test Concurrent Payment Creation
    [Documentation]    Test creating payments concurrently (simulated)
    [Arguments]    ${count}=10
    
    ${start_time}=    Get Current Date    result_format=epoch
    
    # Simulate concurrent requests by creating payments rapidly
    FOR    ${i}    IN RANGE    ${count}
        ${amount}=    Evaluate    50 + ${i}
        ${response}=    Create Payment    ${amount}    USD    Concurrent payment ${i}
        Verify Payment Data    ${response}    ${amount}    USD    Concurrent payment ${i}
    END
    
    ${end_time}=    Get Current Date    result_format=epoch
    ${total_time}=    Evaluate    ${end_time} - ${start_time}
    
    Log    Created ${count} payments concurrently in ${total_time}s
    Should Be True    ${total_time} < ${MAX_CONCURRENT_TIME}    Concurrent payment creation should complete within ${MAX_CONCURRENT_TIME} seconds

Test Large Amount Handling
    [Documentation]    Test handling of large payment amounts
    ${large_amounts}=    Create List    999999.99    1000000.00    9999999.99
    
    FOR    ${amount}    IN    @{large_amounts}
        ${response}=    Create Payment    ${amount}    USD    Large amount test: ${amount}
        Verify Payment Data    ${response}    ${amount}    USD    Large amount test: ${amount}
    END

Test High Precision Amounts
    [Documentation]    Test handling of high precision decimal amounts
    ${precision_amounts}=    Create List    123.456789    0.01    999.999999
    
    FOR    ${amount}    IN    @{precision_amounts}
        ${response}=    Create Payment    ${amount}    USD    Precision test: ${amount}
        Verify Payment Data    ${response}    ${amount}    USD    Precision test: ${amount}
    END

Test Memory Usage Stability
    [Documentation]    Test that API remains stable under repeated requests
    [Arguments]    ${batches}=5    ${requests_per_batch}=10
    
    FOR    ${batch}    IN RANGE    ${batches}
        Log    Processing batch ${batch + 1}
        FOR    ${i}    IN RANGE    ${requests_per_batch}
            ${amount}=    Evaluate    100 + ${i}
            ${response}=    Create Payment    ${amount}    USD    Batch ${batch} payment ${i}
            Verify Payment Data    ${response}    ${amount}    USD    Batch ${batch} payment ${i}
        END
        # Small delay between batches
        Sleep    0.5s
    END
    
    # Verify API is still responsive
    api_keywords.Health Check

Test Response Time Under Load
    [Documentation]    Test response times under various load conditions
    [Arguments]    ${load_level}=medium
    
    # Set count based on load level
    IF    '${load_level}' == 'light'
        ${count}=    Set Variable    5
    ELSE IF    '${load_level}' == 'medium'
        ${count}=    Set Variable    20
    ELSE IF    '${load_level}' == 'heavy'
        ${count}=    Set Variable    50
    ELSE
        Fail    Unknown load level: ${load_level}
    END
    
    ${start_time}=    Get Current Date    result_format=epoch
    
    FOR    ${i}    IN RANGE    ${count}
        ${amount}=    Evaluate    100 + ${i}
        ${response}=    Create Payment    ${amount}    USD    Load test payment ${i}
        Verify Payment Data    ${response}    ${amount}    USD    Load test payment ${i}
    END
    
    ${end_time}=    Get Current Date    result_format=epoch
    ${total_time}=    Evaluate    ${end_time} - ${start_time}
    ${avg_time}=    Evaluate    ${total_time} / ${count}
    
    Log    Load test (${load_level}): ${count} payments in ${total_time}s (avg: ${avg_time}s per payment)
    
    # Set different expectations based on load level
    IF    '${load_level}' == 'light'
        ${max_avg_time}=    Set Variable    1
    ELSE IF    '${load_level}' == 'medium'
        ${max_avg_time}=    Set Variable    2
    ELSE IF    '${load_level}' == 'heavy'
        ${max_avg_time}=    Set Variable    5
    ELSE
        Fail    Unknown load level: ${load_level}
    END
    Should Be True    ${avg_time} < ${max_avg_time}    Average response time should be less than ${max_avg_time} seconds for ${load_level} load

Test API Stress Test
    [Documentation]    Comprehensive stress test for the API
    [Arguments]    ${duration_seconds}=60
    
    ${start_time}=    Get Current Date    result_format=epoch
    ${end_time}=    Evaluate    ${start_time} + ${duration_seconds}
    ${request_count}=    Set Variable    0
    
    WHILE    ${start_time} < ${end_time}
        ${amount}=    Evaluate    100 + ${request_count}
        ${response}=    Create Payment    ${amount}    USD    Stress test payment ${request_count}
        Verify Payment Data    ${response}    ${amount}    USD    Stress test payment ${request_count}
        ${request_count}=    Evaluate    ${request_count} + 1
        ${start_time}=    Get Current Date    result_format=epoch
    END
    
    Log    Stress test completed: ${request_count} requests in ${duration_seconds} seconds
    Should Be True    ${request_count} > 0    Should have made at least one request during stress test