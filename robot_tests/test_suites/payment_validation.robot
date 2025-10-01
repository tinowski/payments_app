*** Settings ***
Documentation    Payment validation test suite
Resource        ../keywords/api_keywords.robot
Resource        ../keywords/validation_keywords.robot
Resource        ../keywords/common_keywords.robot
Test Setup      Start API Session
Test Teardown   Delete All Sessions

*** Test Cases ***
Test Create Payment With Invalid Amount
    [Documentation]    Test creating payment with invalid amount
    Test Invalid Payment Creation    -100    USD    Invalid amount    amount must be greater than 0

Test Create Payment With Zero Amount
    [Documentation]    Test creating payment with zero amount
    Test Invalid Payment Creation    0    USD    Zero amount    amount must be greater than 0

Test Create Payment With Empty Currency
    [Documentation]    Test creating payment with empty currency
    Test Invalid Payment Creation    100    ${EMPTY}    Empty currency    currency is required

Test Create Payment With Empty Description
    [Documentation]    Test creating payment with empty description
    Test Invalid Payment Creation    100    USD    ${EMPTY}    description is required

Test Create Payment With Whitespace Currency
    [Documentation]    Test creating payment with whitespace-only currency
    Test Whitespace Validation    currency    "   "

Test Create Payment With Whitespace Description
    [Documentation]    Test creating payment with whitespace-only description
    Test Whitespace Validation    description    "   "

Test Update Payment With Invalid Amount
    [Documentation]    Test updating payment with invalid amount
    ${create_response}=    Create Payment    100.00    USD    Valid payment
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    Test Invalid Payment Update    ${payment_id}    -50    ${EMPTY}    ${EMPTY}    amount must be greater than 0

Test Update Payment With Empty Currency
    [Documentation]    Test updating payment with empty currency
    ${create_response}=    Create Payment    100.00    USD    Valid payment
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    Test Invalid Payment Update    ${payment_id}    ${EMPTY}    ${EMPTY}    ${EMPTY}    currency is required

Test Update Payment With Empty Description
    [Documentation]    Test updating payment with empty description
    ${create_response}=    Create Payment    100.00    USD    Valid payment
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    Test Invalid Payment Update    ${payment_id}    ${EMPTY}    ${EMPTY}    ${EMPTY}    description is required

Test Get Non-Existent Payment
    [Documentation]    Test getting a non-existent payment
    Test Get Non-Existent Payment    non-existent-id    payment not found

Test Update Non-Existent Payment
    [Documentation]    Test updating a non-existent payment
    Test Update Non-Existent Payment    non-existent-id    payment not found

Test Delete Non-Existent Payment
    [Documentation]    Test deleting a non-existent payment
    Test Delete Non-Existent Payment    non-existent-id    payment not found

Test Create Payment With Special Characters
    [Documentation]    Test creating payment with special characters in description
    Test Special Characters    Payment with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?

Test Create Payment With Unicode Characters
    [Documentation]    Test creating payment with unicode characters
    Test Unicode Characters    Payment with unicode: 测试支付 🚀 €£¥

Test Create Payment With Very Long Description
    [Documentation]    Test creating payment with very long description
    ${long_description}=    Set Variable    This is a very long description for testing purposes. It contains multiple sentences and should test the system's ability to handle longer text inputs. The description should be stored and retrieved correctly without any truncation or data loss. This test ensures that the payment system can handle realistic business scenarios where payment descriptions might be quite detailed and lengthy.
    Test Long Description    ${long_description}
