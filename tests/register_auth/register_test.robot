*** Settings ***
Library           RequestsLibrary
Library    Collections
Resource          ../../tests/support_keywords/set_token.resource

*** Variables ***
${BASE_URL}       http://127.0.0.1:5000/api/v1/auth
${ADMIN_EMAIL}    admin@example.com
${ADMIN_PASS}     admin123

*** Test Cases ***
Test Successful User Registration
    [Documentation]    Test Successful User Registration
    [Tags]    registerauth
    ${payload}    Create Dictionary    email=testuser@example.com    password=StrongPass123!    name=Test User
    ${response}    Post    ${BASE_URL}/register    json=${payload}
    Should Be Equal As Numbers    ${response.status_code}    201
    Dictionary Should Contain Value    ${response.json()}    User registered successfully.

Test Duplicate User Registration
    [Documentation]    Test Duplicate User Registration
    [Tags]    registerauth
    ${payload}    Create Dictionary    email=existinguser@example.com    password=StrongPass123!
    ${response}    Post    ${BASE_URL}/register    json=${payload}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    409
    Dictionary Should Contain Value    ${response.json()}    A user with this email already exists.


Test Login and Validate Token is generated
    [Documentation]    Test Login and Validate Token is generated
    [Tags]    registerauth
    ${login_payload}    Create Dictionary    email=admin@example.com    password=admin123
    ${login_response}   POST    ${BASE_URL}/login    json=${login_payload}
    ${token}            Set Variable    ${login_response.json()['token']}
    Should Be Equal As Numbers    ${login_response.status_code}    200

Logout with Valid Token
    [Documentation]    Verify logout with a valid admin token is successful.
    [Tags]    registerauth
    ${headers}=    Set up Admin token
    ${response}=    GET    ${BASE_URL}/logout    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Contain    ${response.json()['message']}    Logout successful

Logout with Missing Token
    [Documentation]    Verify logout fails when no token is provided.
    [Tags]    registerauth
    ${response}=    GET    ${BASE_URL}/logout    expected_status=anything
    Should Be Equal As Integers    ${response.status_code}    401
    Should Contain    ${response.json()['error']}    Authorization token missing

Logout with Invalid Token
    [Documentation]    Verify logout fails with an invalid token.
    [Tags]    registerauth
    ${headers}=    Create Dictionary    Authorization=incorrect_token
    ${response}=    GET    ${BASE_URL}/logout    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${response.status_code}    403
    Should Contain    ${response.json()['error']}    Invalid or expired token