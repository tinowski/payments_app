*** Settings ***
Documentation    Assertion and verification keywords for Robot Framework tests
Library          Collections
Library          JSONLibrary
Library          String

*** Keywords ***
Assert Payment Created Successfully
    [Documentation]    Assert that payment was created successfully
    [Arguments]    ${response}    ${expected_amount}    ${expected_currency}    ${expected_description}    ${expected_status}=PENDING
    
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    
    # Verify payment data
    Should Be Equal As Numbers    ${json['data']['createPayment']['amount']}    ${expected_amount}
    Should Be Equal As Strings    ${json['data']['createPayment']['currency']}    ${expected_currency}
    Should Be Equal As Strings    ${json['data']['createPayment']['description']}    ${expected_description}
    Should Be Equal As Strings    ${json['data']['createPayment']['status']}    ${expected_status}
    
    # Verify required fields exist
    Should Not Be Equal    ${json['data']['createPayment']['id']}    ${None}
    Should Not Be Equal    ${json['data']['createPayment']['createdAt']}    ${None}
    Should Not Be Equal    ${json['data']['createPayment']['updatedAt']}    ${None}

Assert Payment Updated Successfully
    [Documentation]    Assert that payment was updated successfully
    [Arguments]    ${response}    ${expected_amount}=${EMPTY}    ${expected_currency}=${EMPTY}    ${expected_description}=${EMPTY}    ${expected_status}=${EMPTY}
    
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    
    # Verify updated fields if provided
    Run Keyword If    '${expected_amount}' != '${EMPTY}'    Should Be Equal As Numbers    ${json['data']['updatePayment']['amount']}    ${expected_amount}
    Run Keyword If    '${expected_currency}' != '${EMPTY}'    Should Be Equal As Strings    ${json['data']['updatePayment']['currency']}    ${expected_currency}
    Run Keyword If    '${expected_description}' != '${EMPTY}'    Should Be Equal As Strings    ${json['data']['updatePayment']['description']}    ${expected_description}
    Run Keyword If    '${expected_status}' != '${EMPTY}'    Should Be Equal As Strings    ${json['data']['updatePayment']['status']}    ${expected_status}

Assert Payment Deleted Successfully
    [Documentation]    Assert that payment was deleted successfully
    [Arguments]    ${response}
    
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    Should Be True    ${json['data']['deletePayment']}

Assert Payment Retrieved Successfully
    [Documentation]    Assert that payment was retrieved successfully
    [Arguments]    ${response}    ${expected_amount}=${EMPTY}    ${expected_currency}=${EMPTY}    ${expected_description}=${EMPTY}    ${expected_status}=${EMPTY}
    
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    Should Not Be Equal    ${json['data']['payment']}    ${None}
    
    # Verify payment data if provided
    Run Keyword If    '${expected_amount}' != '${EMPTY}'    Should Be Equal As Numbers    ${json['data']['payment']['amount']}    ${expected_amount}
    Run Keyword If    '${expected_currency}' != '${EMPTY}'    Should Be Equal As Strings    ${json['data']['payment']['currency']}    ${expected_currency}
    Run Keyword If    '${expected_description}' != '${EMPTY}'    Should Be Equal As Strings    ${json['data']['payment']['description']}    ${expected_description}
    Run Keyword If    '${expected_status}' != '${EMPTY}'    Should Be Equal As Strings    ${json['data']['payment']['status']}    ${expected_status}

Assert Payment Not Found
    [Documentation]    Assert that payment was not found
    [Arguments]    ${response}
    
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal    ${json['data']['payment']}    ${None}

Assert Validation Error
    [Documentation]    Assert that validation error occurred
    [Arguments]    ${response}    ${expected_error}
    
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json}    errors
    Should Contain    ${json['errors'][0]['message']}    ${expected_error}

Assert API Health
    [Documentation]    Assert that API health check passes
    [Arguments]    ${response}
    
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    OK

Assert Response Time
    [Documentation]    Assert that response time is within acceptable limits
    [Arguments]    ${response_time}    ${max_time}=5
    
    Should Be True    ${response_time} < ${max_time}    Response time should be less than ${max_time} seconds, got ${response_time}s

Assert Payment Status
    [Documentation]    Assert that payment has specific status
    [Arguments]    ${payment_id}    ${expected_status}
    ${response}=    Get Payment    ${payment_id}
    Should Be Equal As Strings    ${response['data']['payment']['status']}    ${expected_status}

Assert Payment Amount
    [Documentation]    Assert that payment has specific amount
    [Arguments]    ${payment_id}    ${expected_amount}
    ${response}=    Get Payment    ${payment_id}
    Should Be Equal As Numbers    ${response['data']['payment']['amount']}    ${expected_amount}

Assert Payment Currency
    [Documentation]    Assert that payment has specific currency
    [Arguments]    ${payment_id}    ${expected_currency}
    ${response}=    Get Payment    ${payment_id}
    Should Be Equal As Strings    ${response['data']['payment']['currency']}    ${expected_currency}

Assert Payment Description
    [Documentation]    Assert that payment has specific description
    [Arguments]    ${payment_id}    ${expected_description}
    ${response}=    Get Payment    ${payment_id}
    Should Be Equal As Strings    ${response['data']['payment']['description']}    ${expected_description}

Assert Multiple Payments Created
    [Documentation]    Assert that multiple payments were created successfully
    [Arguments]    ${payment_responses}    ${expected_count}
    
    ${actual_count}=    Get Length    ${payment_responses}
    Should Be Equal As Numbers    ${actual_count}    ${expected_count}
    
    FOR    ${response}    IN    @{payment_responses}
        Should Be Equal As Strings    ${response.status_code}    200
        ${json}=    Set Variable    ${response.json()}
        Should Not Contain    ${json}    errors
    END

Assert Performance Metrics
    [Documentation]    Assert that performance metrics meet requirements
    [Arguments]    ${total_time}    ${request_count}    ${max_avg_time}=2
    
    ${avg_time}=    Evaluate    ${total_time} / ${request_count}
    Should Be True    ${avg_time} < ${max_avg_time}    Average response time should be less than ${max_avg_time} seconds, got ${avg_time}s

Assert No Memory Leaks
    [Documentation]    Assert that API remains stable after repeated requests
    [Arguments]    ${initial_response_time}    ${final_response_time}    ${tolerance}=2
    
    ${time_difference}=    Evaluate    abs(${final_response_time} - ${initial_response_time})
    Should Be True    ${time_difference} < ${tolerance}    Response time should not degrade significantly, difference: ${time_difference}s
