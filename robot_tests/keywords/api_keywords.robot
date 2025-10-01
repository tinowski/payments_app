*** Settings ***
Documentation    API communication keywords for Robot Framework tests
Resource        ../setup/global_setup.robot
Library          RequestsLibrary
Library          Collections
Library          JSONLibrary
Library          String

*** Variables ***
${BASE_URL}      http://localhost:8080

*** Keywords ***
Start API Session
    [Documentation]    Initialize API session for testing
    Create Session    payments_api    ${BASE_URL}    headers={'Content-Type': 'application/json'}

Health Check
    [Documentation]    Verify API health endpoint
    ${response}=    GET On Session    payments_api    /health
    Should Be Equal As Strings    ${response.status_code}    200
    Should Contain    ${response.text}    OK

Send GraphQL Request
    [Documentation]    Send GraphQL request and return response
    [Arguments]    ${query}    ${variables}=${EMPTY}
    ${payload}=    Create Dictionary
    Set To Dictionary    ${payload}    query    ${query}
    Run Keyword If    '${variables}' != '${EMPTY}'    Set To Dictionary    ${payload}    variables    ${variables}
    
    ${response}=    POST On Session    payments_api    /query    json=${payload}
    RETURN    ${response}

Create Payment
    [Documentation]    Create a new payment via GraphQL
    [Arguments]    ${amount}    ${currency}    ${description}
    ${escaped_description}=    Replace String    ${description}    "    \"
    ${escaped_description}=    Replace String    ${escaped_description}    \    \\
    ${query}=    Set Variable    mutation { createPayment(input: { amount: ${amount}, currency: "${currency}", description: "${escaped_description}" }) { id amount currency description status createdAt updatedAt } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    RETURN    ${json}

Get Payment
    [Documentation]    Get payment by ID via GraphQL
    [Arguments]    ${payment_id}
    ${query}=    Set Variable    query { payment(id: "${payment_id}") { id amount currency description status createdAt updatedAt } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    RETURN    ${json}

Get All Payments
    [Documentation]    Get all payments via GraphQL
    ${query}=    Set Variable    query { payments { id amount currency description status createdAt updatedAt } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    RETURN    ${json}

Update Payment
    [Documentation]    Update payment via GraphQL
    [Arguments]    ${payment_id}    ${amount}=${EMPTY}    ${currency}=${EMPTY}    ${description}=${EMPTY}    ${status}=${EMPTY}
    
    # Build the input object dynamically
    ${input_parts}=    Create List    id: "${payment_id}"
    
    Run Keyword If    '${amount}' != '${EMPTY}' and '${amount}' != 'None'    Append To List    ${input_parts}    amount: ${amount}
    Run Keyword If    '${currency}' != '${EMPTY}' and '${currency}' != 'None'    Append To List    ${input_parts}    currency: "${currency}"
    Run Keyword If    '${description}' != '${EMPTY}' and '${description}' != 'None'    Append To List    ${input_parts}    description: "${description}"
    Run Keyword If    '${status}' != '${EMPTY}' and '${status}' != 'None'    Append To List    ${input_parts}    status: ${status}
    
    ${input_string}=    Evaluate    ', '.join($input_parts)
    ${query}=    Set Variable    mutation { updatePayment(input: { ${input_string} }) { id amount currency description status createdAt updatedAt } }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    RETURN    ${json}

Delete Payment
    [Documentation]    Delete payment via GraphQL
    [Arguments]    ${payment_id}
    ${query}=    Set Variable    mutation { deletePayment(id: "${payment_id}") }
    ${response}=    Send GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Not Contain    ${json}    errors
    RETURN    ${json}

Wait For Server
    [Documentation]    Wait for server to be ready
    [Arguments]    ${timeout}=30
    FOR    ${i}    IN RANGE    ${timeout}
        ${response}=    Run Keyword And Return Status    Health Check
        Exit For Loop If    ${response}
        Sleep    1s
    END
    Should Be True    ${response}    Server did not start within ${timeout} seconds
