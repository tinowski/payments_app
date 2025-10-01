*** Settings ***
Documentation    Test suite dispatcher for Payments API - runs different test suites
Resource        keywords/api_keywords.robot
Resource        keywords/common_keywords.robot
Suite Setup     Start API Session
Suite Teardown  Delete All Sessions

*** Test Cases ***
Run All Payment CRUD Tests
    [Documentation]    Run all CRUD operation tests
    [Tags]    crud    smoke
    Log    Running Payment CRUD Tests
    # Note: This test case serves as a dispatcher - actual tests are in test_suites/payment_crud.robot

Run All Payment Validation Tests
    [Documentation]    Run all validation tests
    [Tags]    validation    negative
    Log    Running Payment Validation Tests
    # Note: This test case serves as a dispatcher - actual tests are in test_suites/payment_validation.robot

Run All Performance Tests
    [Documentation]    Run all performance tests
    [Tags]    performance    load
    Log    Running Performance Tests
    # Note: This test case serves as a dispatcher - actual tests are in test_suites/performance_tests.robot

Run Comprehensive Test Suite
    [Documentation]    Run the comprehensive test suite with all test scenarios
    [Tags]    comprehensive    all
    Log    Running Comprehensive Test Suite
    # Note: This test case serves as a dispatcher - actual tests are in run_simple_tests.robot
