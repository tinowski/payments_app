*** Settings ***
Documentation    Test data generation and management keywords
Library          Collections
Library          String

*** Variables ***
@{VALID_CURRENCIES}    USD    EUR    GBP    JPY    CAD    AUD    CHF    CNY
@{VALID_STATUSES}      PENDING    COMPLETED    CANCELLED    FAILED

*** Keywords ***
Generate Test Payment Data
    [Documentation]    Generate test payment data with various scenarios
    [Arguments]    ${scenario}=normal
    ${data}=    Create Dictionary
    
    Run Keyword If    '${scenario}' == 'normal'    Set Normal Payment Data    ${data}
    Run Keyword If    '${scenario}' == 'large_amount'    Set Large Amount Payment Data    ${data}
    Run Keyword If    '${scenario}' == 'precision'    Set Precision Payment Data    ${data}
    Run Keyword If    '${scenario}' == 'unicode'    Set Unicode Payment Data    ${data}
    Run Keyword If    '${scenario}' == 'special_chars'    Set SpecialChars Payment Data    ${data}
    
    RETURN    ${data}

Set Normal Payment Data
    [Documentation]    Set normal payment data
    [Arguments]    ${data}
    ${amount}=    Evaluate    random.randint(1, 1000)    modules=random
    ${currency}=    Get From List    ${VALID_CURRENCIES}    0
    ${description}=    Set Variable    Test payment ${amount}
    
    Set To Dictionary    ${data}    amount    ${amount}
    Set To Dictionary    ${data}    currency    ${currency}
    Set To Dictionary    ${data}    description    ${description}

Set Large Amount Payment Data
    [Documentation]    Set large amount payment data
    [Arguments]    ${data}
    ${amount}=    Evaluate    random.randint(100000, 9999999)    modules=random
    ${currency}=    Get From List    ${VALID_CURRENCIES}    0
    ${description}=    Set Variable    Large amount test payment ${amount}
    
    Set To Dictionary    ${data}    amount    ${amount}
    Set To Dictionary    ${data}    currency    ${currency}
    Set To Dictionary    ${data}    description    ${description}

Set Precision Payment Data
    [Documentation]    Set high precision payment data
    [Arguments]    ${data}
    ${amount}=    Evaluate    round(random.uniform(0.01, 999.99), 6)    modules=random
    ${currency}=    Get From List    ${VALID_CURRENCIES}    0
    ${description}=    Set Variable    Precision test payment ${amount}
    
    Set To Dictionary    ${data}    amount    ${amount}
    Set To Dictionary    ${data}    currency    ${currency}
    Set To Dictionary    ${data}    description    ${description}

Set Unicode Payment Data
    [Documentation]    Set unicode payment data
    [Arguments]    ${data}
    ${amount}=    Evaluate    random.randint(1, 1000)    modules=random
    ${currency}=    Get From List    ${VALID_CURRENCIES}    0
    ${description}=    Set Variable    测试支付 🚀 €£¥ ${amount}
    
    Set To Dictionary    ${data}    amount    ${amount}
    Set To Dictionary    ${data}    currency    ${currency}
    Set To Dictionary    ${data}    description    ${description}

Set SpecialChars Payment Data
    [Documentation]    Set special characters payment data
    [Arguments]    ${data}
    ${amount}=    Evaluate    random.randint(1, 1000)    modules=random
    ${currency}=    Get From List    ${VALID_CURRENCIES}    0
    ${description}=    Set Variable    Payment with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>? ${amount}
    
    Set To Dictionary    ${data}    amount    ${amount}
    Set To Dictionary    ${data}    currency    ${currency}
    Set To Dictionary    ${data}    description    ${description}

Generate Invalid Payment Data
    [Documentation]    Generate invalid payment data for negative testing
    [Arguments]    ${scenario}
    ${data}=    Create Dictionary
    
    Run Keyword If    '${scenario}' == 'negative_amount'    Set Negative Amount Data    ${data}
    Run Keyword If    '${scenario}' == 'zero_amount'    Set Zero Amount Data    ${data}
    Run Keyword If    '${scenario}' == 'empty_currency'    Set Empty Currency Data    ${data}
    Run Keyword If    '${scenario}' == 'empty_description'    Set Empty Description Data    ${data}
    Run Keyword If    '${scenario}' == 'whitespace_currency'    Set Whitespace Currency Data    ${data}
    Run Keyword If    '${scenario}' == 'whitespace_description'    Set Whitespace Description Data    ${data}
    
    RETURN    ${data}

Set Negative Amount Data
    [Documentation]    Set negative amount data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    -100
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    Invalid negative amount
    Set To Dictionary    ${data}    expected_error    amount must be greater than 0

Set Zero Amount Data
    [Documentation]    Set zero amount data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    0
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    Invalid zero amount
    Set To Dictionary    ${data}    expected_error    amount must be greater than 0

Set Empty Currency Data
    [Documentation]    Set empty currency data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100
    Set To Dictionary    ${data}    currency    ${EMPTY}
    Set To Dictionary    ${data}    description    Invalid empty currency
    Set To Dictionary    ${data}    expected_error    currency is required

Set Empty Description Data
    [Documentation]    Set empty description data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    ${EMPTY}
    Set To Dictionary    ${data}    expected_error    description is required

Set Whitespace Currency Data
    [Documentation]    Set whitespace currency data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100
    Set To Dictionary    ${data}    currency    "   "
    Set To Dictionary    ${data}    description    Invalid whitespace currency
    Set To Dictionary    ${data}    expected_error    currency is required

Set Whitespace Description Data
    [Documentation]    Set whitespace description data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    amount    100
    Set To Dictionary    ${data}    currency    USD
    Set To Dictionary    ${data}    description    "   "
    Set To Dictionary    ${data}    expected_error    description is required

Generate Multiple Test Payments
    [Documentation]    Generate multiple test payments with different scenarios
    [Arguments]    ${count}=5    ${scenario}=normal
    ${payments}=    Create List
    
    FOR    ${i}    IN RANGE    ${count}
        ${payment_data}=    Generate Test Payment Data    ${scenario}
        Append To List    ${payments}    ${payment_data}
    END
    
    RETURN    ${payments}

Generate Performance Test Data
    [Documentation]    Generate test data for performance testing
    [Arguments]    ${test_type}=load
    ${data}=    Create Dictionary
    
    Run Keyword If    '${test_type}' == 'load'    Set Load Test Data    ${data}
    Run Keyword If    '${test_type}' == 'stress'    Set Stress Test Data    ${data}
    Run Keyword If    '${test_type}' == 'memory'    Set Memory Test Data    ${data}
    
    RETURN    ${data}

Set Load Test Data
    [Documentation]    Set load test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    request_count    20
    Set To Dictionary    ${data}    max_response_time    2
    Set To Dictionary    ${data}    concurrent_requests    5

Set Stress Test Data
    [Documentation]    Set stress test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    request_count    100
    Set To Dictionary    ${data}    max_response_time    5
    Set To Dictionary    ${data}    concurrent_requests    10

Set Memory Test Data
    [Documentation]    Set memory test data
    [Arguments]    ${data}
    Set To Dictionary    ${data}    batches    5
    Set To Dictionary    ${data}    requests_per_batch    10
    Set To Dictionary    ${data}    batch_delay    0.5
