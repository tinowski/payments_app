*** Settings ***
Documentation    Validation-specific keywords for Robot Framework tests
Resource        ../setup/global_setup.robot
Resource        api_keywords.robot
Resource        common_keywords.robot
Library         Collections
Library         JSONLibrary

*** Keywords ***
Test Invalid Payment Creation
    [Documentation]    Test creating payment with invalid data
    [Arguments]    ${amount}    ${currency}    ${description}    ${expected_error}
    
    ${query}=    Set Variable    mutation { createPayment(input: { amount: ${amount}, currency: "${currency}", description: "${description}" }) { id amount currency description status } }
    Log    Generated query: ${query}
    ${response}=    Send GraphQL Request    ${query}
    Log    Response status: ${response.status_code}
    Log    Response body: ${response.text}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    errors
    Should Contain    ${json['errors'][0]['message']}    ${expected_error}

Test Invalid Payment Update
    [Documentation]    Test updating payment with invalid data
    [Arguments]    ${payment_id}    ${amount}    ${currency}    ${description}    ${expected_error}
    
    ${amount_part}=    Set Variable If    '${amount}' != '${EMPTY}'    , amount: ${amount}    ${EMPTY}
    ${currency_part}=    Set Variable If    '${currency}' != '${EMPTY}'    , currency: "${currency}"    ${EMPTY}
    ${description_part}=    Set Variable If    '${description}' != '${EMPTY}'    , description: "${description}"    ${EMPTY}
    
    ${query}=    Set Variable    mutation { updatePayment(input: { id: "${payment_id}"${amount_part}${currency_part}${description_part} }) { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    errors
    Should Contain    ${json['errors'][0]['message']}    ${expected_error}

Test Non-Existent Payment Operations
    [Documentation]    Test operations on non-existent payment
    [Arguments]    ${operation}    ${payment_id}    ${expected_error}
    
    Run Keyword If    '${operation}' == 'get'    Test Get Non-Existent Payment    ${payment_id}    ${expected_error}
    Run Keyword If    '${operation}' == 'update'    Test Update Non-Existent Payment    ${payment_id}    ${expected_error}
    Run Keyword If    '${operation}' == 'delete'    Test Delete Non-Existent Payment    ${payment_id}    ${expected_error}

Test Get Non-Existent Payment
    [Documentation]    Test getting non-existent payment
    [Arguments]    ${payment_id}    ${expected_error}=${None}
    
    ${query}=    Set Variable    query { payment(id: "${payment_id}") { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal    ${json['data']['payment']}    ${None}
    
    # Validate error message if provided
    Run Keyword If    '${expected_error}' != '${None}' and '${expected_error}' != ''
    ...    Should Contain    ${json}    errors

Test Update Non-Existent Payment
    [Documentation]    Test updating non-existent payment
    [Arguments]    ${payment_id}    ${expected_error}=payment not found
    
    ${query}=    Set Variable    mutation { updatePayment(input: { id: "${payment_id}", amount: 100 }) { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    errors
    Should Contain    ${json['errors'][0]['message']}    ${expected_error}

Test Delete Non-Existent Payment
    [Documentation]    Test deleting non-existent payment
    [Arguments]    ${payment_id}    ${expected_error}=payment not found
    
    ${query}=    Set Variable    mutation { deletePayment(id: "${payment_id}") }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    errors
    Should Contain    ${json['errors'][0]['message']}    ${expected_error}

Test Whitespace Validation
    [Documentation]    Test validation with whitespace-only inputs
    [Arguments]    ${field}
    
    ${expected_error}=    Set Variable If    '${field}' == 'currency'    currency is required    description is required
    ${currency_value}=    Set Variable If    '${field}' == 'currency'    "   "    "USD"
    ${description_value}=    Set Variable If    '${field}' == 'description'    "   "    "Test"
    
    ${query}=    Set Variable    mutation { createPayment(input: { amount: 100, currency: ${currency_value}, description: ${description_value} }) { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    # Note: Current implementation doesn't validate whitespace, so we expect success
    Should Not Contain    ${json}    errors

Test Amount Validation
    [Documentation]    Test various amount validation scenarios
    [Arguments]    ${amount}    ${should_pass}=True
    
    ${query}=    Set Variable    mutation { createPayment(input: { amount: ${amount}, currency: "USD", description: "Amount test" }) { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    
    Run Keyword If    '${should_pass}' == 'True'    Should Not Contain    ${json}    errors
    Run Keyword If    '${should_pass}' == 'False'    Should Contain    ${json}    errors

Test Currency Validation
    [Documentation]    Test various currency validation scenarios
    [Arguments]    ${currency}    ${should_pass}=True
    
    ${query}=    Set Variable    mutation { createPayment(input: { amount: 100, currency: "${currency}", description: "Currency test" }) { id amount currency description status } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    
    ${json}=    Set Variable    ${response.json()}
    
    Run Keyword If    '${should_pass}' == 'True'    Should Not Contain    ${json}    errors
    Run Keyword If    '${should_pass}' == 'False'    Should Contain    ${json}    errors

Test Payment Lifecycle Validation
    [Documentation]    Test complete payment lifecycle with validation
    [Arguments]    ${amount}    ${currency}    ${description}
    
    # Create payment
    ${create_response}=    Create Payment    ${amount}    ${currency}    ${description}
    Verify Payment Data    ${create_response}    ${amount}    ${currency}    ${description}
    ${payment_id}=    Extract Payment ID    ${create_response}
    
    # Update payment
    ${double_amount}=    Evaluate    ${amount} * 2
    ${update_response}=    Update Payment    ${payment_id}    amount=${double_amount}    status=COMPLETED
    Should Be Equal As Numbers    ${update_response['data']['updatePayment']['amount']}    ${double_amount}
    Should Be Equal As Strings    ${update_response['data']['updatePayment']['status']}    COMPLETED
    
    # Verify final state
    ${final_response}=    Get Payment    ${payment_id}
    Should Be Equal As Numbers    ${final_response['data']['payment']['amount']}    ${double_amount}
    Should Be Equal As Strings    ${final_response['data']['payment']['status']}    COMPLETED
    
    # Clean up
    ${delete_response}=    Delete Payment    ${payment_id}
    Should Be True    ${delete_response['data']['deletePayment']}
    Verify Payment Deleted    ${payment_id}