*** Settings ***
Documentation    Simple test runner for Payments API Robot Framework tests
Resource        keywords/api_keywords.robot
Resource        keywords/common_keywords.robot
Suite Setup     Start API Session
Suite Teardown  Delete All Sessions

*** Test Cases ***
# Smoke Tests - Critical functionality
Test API Health
    [Documentation]    Verify API health endpoint is working
    [Tags]    smoke    critical
    api_keywords.Health Check

Test Basic Payment CRUD
    [Documentation]    Test basic payment CRUD operations
    [Tags]    smoke    crud
    # Create payment
    ${response}=    Create Payment    100.00    USD    Smoke test payment
    Verify Payment Data    ${response}    100.00    USD    Smoke test payment
    
    # Get payment
    ${payment_id}=    Extract Payment ID    ${response}
    ${get_response}=    Get Payment    ${payment_id}
    Should Not Be Equal    ${get_response['data']['payment']}    ${None}
    
    # Update payment
    ${update_response}=    Update Payment    ${payment_id}    amount=200.00    status=COMPLETED
    Should Be Equal As Numbers    ${update_response['data']['updatePayment']['amount']}    200.00
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['status']}    COMPLETED
    
    # Delete payment
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}

Test Payment Validation
    [Documentation]    Test payment validation
    [Tags]    validation    negative
    # Test invalid amount
    ${query}=    Set Variable    mutation { createPayment(input: { amount: -100, currency: "USD", description: "Invalid amount" }) { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    errors
    Should Contain    ${json['errors'][0]['message']}    amount must be greater than 0

Test Payment Performance
    [Documentation]    Test payment creation performance
    [Tags]    performance
    ${start_time}=    Get Current Date    result_format=epoch
    
    # Create multiple payments
    FOR    ${i}    IN RANGE    5
        ${amount}=    Evaluate    100 + ${i}
        ${response}=    Create Payment    ${amount}    USD    Performance test payment ${i}
        Verify Payment Data    ${response}    ${amount}    USD    Performance test payment ${i}
    END
    
    ${end_time}=    Get Current Date    result_format=epoch
    ${total_time}=    Evaluate    ${end_time} - ${start_time}
    ${avg_time}=    Evaluate    ${total_time} / 5
    
    Log    Created 5 payments in ${total_time}s (avg: ${avg_time}s per payment)
    Should Be True    ${avg_time} < 2    Average response time should be less than 2 seconds

Test Different Currencies
    [Documentation]    Test payments with different currencies
    [Tags]    regression
    ${currencies}=    Create List    USD    EUR    GBP    JPY
    FOR    ${currency}    IN    @{currencies}
        ${response}=    Create Payment    50.00    ${currency}    Payment in ${currency}
        Verify Payment Data    ${response}    50.00    ${currency}    Payment in ${currency}
        
        ${payment_id}=    Extract Payment ID    ${response}
        ${delete_response}=    Delete Payment    ${payment_id}
        Should Be True    ${delete_response['data']['deletePayment']}
    END

Test Special Characters
    [Documentation]    Test payments with special characters
    [Tags]    regression
    ${response}=    Create Payment    100.00    USD    Payment with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?
    Verify Payment Data    ${response}    100.00    USD    Payment with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?
    
    ${payment_id}=    Extract Payment ID    ${response}
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}

Test Unicode Characters
    [Documentation]    Test payments with unicode characters
    [Tags]    regression
    ${response}=    Create Payment    100.00    USD    Payment with unicode: 测试支付 🚀 €£¥
    Verify Payment Data    ${response}    100.00    USD    Payment with unicode: 测试支付 🚀 €£¥
    
    ${payment_id}=    Extract Payment ID    ${response}
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}
