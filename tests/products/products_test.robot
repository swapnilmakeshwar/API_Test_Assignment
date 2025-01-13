*** Settings ***
Library           RequestsLibrary
Library    Collections
Resource          ../../tests/support_keywords/set_token.resource

*** Variables ***
${BASE_URL_AUTH}        http://127.0.0.1:5000/api/v1/auth
${BASE_URL_PRODUCTS}    http://127.0.0.1:5000/api/v1/products

*** Test Cases ***
Test Admin Can Create Product
    [Documentation]    Verify that an admin user can successfully create a product.
    [Tags]    products
    ${login_payload}    Create Dictionary    email=admin@example.com    password=admin123
    ${response}         Post         ${BASE_URL_AUTH}/login    json=${login_payload}
    ${token}            Set Variable         ${response.json()['token']}

    ${product_payload}  Create Dictionary    name=Admin Product    price=50.00
    ${headers}          Create Dictionary    Authorization=${token}
    ${response}         Post         ${BASE_URL_PRODUCTS}    json=${product_payload}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    201

Test Admin Can Not Create Product with Incorrect Token
    [Documentation]    Verify that Admin Can Not create Product with Incorrect Token
    [Tags]    products
    ${headers}=    Set up Incorrect Token
    ${product_payload}  Create Dictionary    name=Admin Product    price=50.00
    
    ${response}         Post         ${BASE_URL_PRODUCTS}    json=${product_payload}    headers=${headers}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    403

Test User Cannot Delete Product
    [Documentation]    Verify that a regular user cannot delete a product.
    [Tags]    products
    ${login_payload}    Create Dictionary    email=user@example.com    password=user123
    ${response}         Post         ${BASE_URL_AUTH}/login    json=${login_payload}
    ${token}            Set Variable         ${response.json()['token']}

    ${headers}          Create Dictionary    Authorization=${token}
    ${response}         Delete       ${BASE_URL_PRODUCTS}/1    headers=${headers}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    403

Test Admin Can Delete Product
    [Documentation]    Verify that an admin user can delete a product.
    [Tags]    products
    ${headers}=    Set up Admin token
    ${response}         Delete       ${BASE_URL_PRODUCTS}/2    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200
    ${message}=    Get From Dictionary    ${response.json()}    message
    Should Contain    ${message}    deleted successfully 
      

Test Retrieve All Products
    [Documentation]    Verify that a logged-in user can retrieve all products.
    [Tags]    products
    ${login_payload}    Create Dictionary    email=user@example.com    password=user123
    ${login_response}   POST    ${BASE_URL_AUTH}/login   json=${login_payload}
    ${token}            Set Variable    ${login_response.json()['token']}
    ${headers}          Create Dictionary    Authorization=${token}
    ${response}         GET    ${BASE_URL_PRODUCTS}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200