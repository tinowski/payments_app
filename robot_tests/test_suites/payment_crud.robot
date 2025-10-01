*** Settings ***
Documentation    Payment CRUD operations test suite
Resource        ../keywords/api_keywords.robot
Resource        ../keywords/common_keywords.robot
Test Setup      Start API Session
Test Teardown   Delete All Sessions

*** Test Cases ***
Test Health Check
    [Documentation]    Verify API health endpoint is working
    api_keywords.Health Check

Test Create Payment
    [Documentation]    Test creating a new payment
    ${response}=    Create Payment    100.50    USD    Test payment via Robot Framework
    Verify Payment Data    ${response}    100.50    USD    Test payment via Robot Framework

Test Create Payment With Different Currencies
    [Documentation]    Test creating payments with different currencies
    ${currencies}=    Create List    USD    EUR    GBP    JPY    CAD
    FOR    ${currency}    IN    @{currencies}
        ${response}=    Create Payment    50.00    ${currency}    Payment in ${currency}
        Verify Payment Data    ${response}    50.00    ${currency}    Payment in ${currency}
    END

Test Create Payment With Large Amount
    [Documentation]    Test creating payment with large amount
    ${response}=    Create Payment    999999.99    USD    Large payment test
    Verify Payment Data    ${response}    999999.99    USD    Large payment test

Test Create Payment With Decimal Amount
    [Documentation]    Test creating payment with decimal amount
    ${response}=    Create Payment    123.456789    USD    Decimal precision test
    Verify Payment Data    ${response}    123.456789    USD    Decimal precision test

Test Get Payment
    [Documentation]    Test retrieving a payment by ID
    ${create_response}=    Create Payment    200.75    EUR    Payment to retrieve
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    ${get_response}=    Get Payment    ${payment_id}
    Should Be Equal As Numbers    ${get_response['data']['payment']['amount']}    200.75
    Should Be Equal As Strings    ${get_response['data']['payment']['currency']}    EUR
    Should Be Equal As Strings    ${get_response['data']['payment']['description']}    Payment to retrieve

Test Get All Payments
    [Documentation]    Test retrieving all payments
    ${response}=    Get All Payments
    Should Not Be Equal    ${response['data']['payments']}    ${None}
    ${payments}=    Get Value From Json    ${response}    $.data.payments
    Should Be True    len(${payments[0]}) >= 0

Test Update Payment Amount
    [Documentation]    Test updating payment amount
    ${create_response}=    Create Payment    100.00    USD    Original payment
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    ${update_response}=    Update Payment    ${payment_id}    amount=250.50
    Should Be Equal As Numbers    ${update_response['data']['updatePayment']['amount']}    250.50
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['currency']}    USD

Test Update Payment Status
    [Documentation]    Test updating payment status
    ${create_response}=    Create Payment    100.00    USD    Status update test
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    ${update_response}=    Update Payment    ${payment_id}    status=COMPLETED
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['status']}    COMPLETED

Test Update Payment Description
    [Documentation]    Test updating payment description
    ${create_response}=    Create Payment    100.00    USD    Original description
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    ${update_response}=    Update Payment    ${payment_id}    description=Updated description
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['description']}    Updated description

Test Update Payment Multiple Fields
    [Documentation]    Test updating multiple payment fields
    ${create_response}=    Create Payment    100.00    USD    Original payment
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    ${update_response}=    Update Payment    ${payment_id}    amount=300.75    currency=EUR    description=Updated payment    status=COMPLETED
    Should Be Equal As Numbers    ${update_response['data']['updatePayment']['amount']}    300.75
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['currency']}    EUR
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['description']}    Updated payment
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['status']}    COMPLETED

Test Delete Payment
    [Documentation]    Test deleting a payment
    ${create_response}=    Create Payment    100.00    USD    Payment to delete
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}
    
    Verify Payment Deleted    ${payment_id}

Test Complete Payment Lifecycle
    [Documentation]    Test complete payment lifecycle: create -> update -> complete -> delete
    # Create payment
    ${create_response}=    Create Payment    500.00    USD    Complete lifecycle test
    ${payment_id}=    Extract Payment ID    ${create_response}
    Verify Payment Data    ${create_response}    500.00    USD    Complete lifecycle test    PENDING
    
    # Update payment
    ${update_response}=    Update Payment    ${payment_id}    amount=750.25    description=Updated lifecycle test
    Should Be Equal As Numbers    ${update_response['data']['updatePayment']['amount']}    750.25
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['description']}    Updated lifecycle test
    
    # Complete payment
    ${complete_response}=    Update Payment    ${payment_id}    status=COMPLETED
    Should Be Equal As Strings    ${complete_response['data']['updatePayment']['status']}    COMPLETED
    
    # Verify final state
    ${final_response}=    Get Payment    ${payment_id}
    Should Be Equal As Numbers    ${final_response['data']['payment']['amount']}    750.25
    Should Be Equal As Strings    ${final_response['data']['payment']['status']}    COMPLETED
    
    # Delete payment
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}
    Verify Payment Deleted    ${payment_id}
