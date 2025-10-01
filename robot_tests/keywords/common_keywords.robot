*** Settings ***
Documentation    Common utility keywords for Robot Framework tests
Library          Collections
Library          JSONLibrary
Library          String
Library          DateTime

*** Keywords ***
Extract Payment ID
    [Documentation]    Extract payment ID from response
    [Arguments]    ${response}
    ${payment_id}=    Get Value From Json    ${response}    $.data.createPayment.id
    RETURN    ${payment_id[0]}

Verify Payment Data
    [Documentation]    Verify payment data matches expected values
    [Arguments]    ${payment_data}    ${expected_amount}    ${expected_currency}    ${expected_description}    ${expected_status}=PENDING
    Should Be Equal As Numbers    ${payment_data['data']['createPayment']['amount']}    ${expected_amount}
    Should Be Equal As Strings    ${payment_data['data']['createPayment']['currency']}    ${expected_currency}
    Should Be Equal As Strings    ${payment_data['data']['createPayment']['description']}    ${expected_description}
    Should Be Equal As Strings    ${payment_data['data']['createPayment']['status']}    ${expected_status}

Verify Payment Exists
    [Documentation]    Verify payment exists in the system
    [Arguments]    ${payment_id}
    ${response}=    Get Payment    ${payment_id}
    Should Not Be Equal    ${response['data']['payment']}    ${None}

Verify Payment Deleted
    [Documentation]    Verify payment has been deleted
    [Arguments]    ${payment_id}
    ${response}=    Get Payment    ${payment_id}
    Should Be Equal    ${response['data']['payment']}    ${None}

Create Multiple Test Payments
    [Documentation]    Create multiple test payments with different data
    [Arguments]    ${payment_data_list}
    ${created_payments}=    Create List
    
    FOR    ${payment_data}    IN    @{payment_data_list}
        ${response}=    Create Payment    ${payment_data['amount']}    ${payment_data['currency']}    ${payment_data['description']}
        ${payment_id}=    Extract Payment ID    ${response}
        Append To List    ${created_payments}    ${payment_id}
    END
    
    RETURN    ${created_payments}

Verify Payment Status
    [Documentation]    Verify payment has specific status
    [Arguments]    ${payment_id}    ${expected_status}
    ${response}=    Get Payment    ${payment_id}
    Should Be Equal As Strings    ${response['data']['payment']['status']}    ${expected_status}

Complete Payment
    [Documentation]    Complete a payment (set status to COMPLETED)
    [Arguments]    ${payment_id}
    ${response}=    Update Payment    ${payment_id}    status=COMPLETED
    Should Be Equal As Strings    ${response['data']['updatePayment']['status']}    COMPLETED
    RETURN    ${response}

Cancel Payment
    [Documentation]    Cancel a payment (set status to CANCELLED)
    [Arguments]    ${payment_id}
    ${response}=    Update Payment    ${payment_id}    status=CANCELLED
    Should Be Equal As Strings    ${response['data']['updatePayment']['status']}    CANCELLED
    RETURN    ${response}

Measure Response Time
    [Documentation]    Measure response time for an operation
    [Arguments]    ${operation}    ${max_time}=5
    ${start_time}=    Get Current Date    result_format=epoch
    ${result}=    Run Keyword    ${operation}
    ${end_time}=    Get Current Date    result_format=epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    
    Log    Operation took ${response_time} seconds
    Should Be True    ${response_time} < ${max_time}    Response time should be less than ${max_time} seconds, got ${response_time}s
    
    RETURN    ${result}

Test Special Characters
    [Documentation]    Test handling of special characters
    [Arguments]    ${description}
    ${response}=    Create Payment    100.00    USD    ${description}
    Verify Payment Data    ${response}    100.00    USD    ${description}

Test Unicode Characters
    [Documentation]    Test handling of unicode characters
    [Arguments]    ${description}
    ${response}=    Create Payment    100.00    USD    ${description}
    Verify Payment Data    ${response}    100.00    USD    ${description}

Test Long Description
    [Documentation]    Test handling of very long descriptions
    [Arguments]    ${description}
    ${response}=    Create Payment    100.00    USD    ${description}
    Verify Payment Data    ${response}    100.00    USD    ${description}
