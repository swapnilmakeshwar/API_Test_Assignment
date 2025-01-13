*** Settings ***
Library           RequestsLibrary
Resource          ../../tests/support_keywords/set_token.resource

*** Variables ***
${BASE_URL}       http://127.0.0.1:5000/api/v1
${ADMIN_TOKEN}    admin_token
${USER_TOKEN}     user_token
${BASE_URL_ORDERS}    http://127.0.0.1:5000/api/v1/orders
*** Test Cases ***
Get All Orders As Admin
    [Documentation]    Verify retrieving all orders as admin.
    [Tags]    orders
    ${headers}=    Set up Admin token
    ${response}=    GET    ${BASE_URL_ORDERS}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200

Get All Orders As User
    [Documentation]    Verify retrieving all orders as a normal user fails.
    [Tags]    orders
    ${headers}=    Set up Normal user token
    ${response}=    GET    ${BASE_URL_ORDERS}    expected_status=anything
    Should Be Equal As Integers    ${response.status_code}    403

Get Single Order By ID As Admin
    [Documentation]    Verify retrieving a single order by ID as admin.
    [Tags]    orders
    ${headers}=    Set up Admin token
    ${response}=    GET    ${BASE_URL_ORDERS}/2    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200
    

Get Single Order By ID As User
    [Documentation]    Verify retrieving a single order by ID as a normal user fails.
    [Tags]    orders
    ${headers}=    Set up Normal user token
    
    ${response}=    GET    ${BASE_URL_ORDERS}/1   headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403

Create New Order
    [Documentation]    Verify creating a new order is successful.
    [Tags]    orders
    ${data}=    Create Dictionary    product_id=1    user_id=2    quantity=3
    ${response}=    POST    ${BASE_URL_ORDERS}    json=${data}
    Should Be Equal As Integers    ${response.status_code}    201
    Should Be True    ${response.json()['id']} != None

Update Order By ID As Admin
    [Documentation]    Verify updating an existing order is successful as admin.
    [Tags]    orders
    Create Session    orders    ${BASE_URL}
    ${headers}=    Set up Admin token
    ${data}=    Create Dictionary    status=Shipped    quantity=1
    ${response}=    PUT    ${BASE_URL_ORDERS}/2    headers=${headers}    json=${data}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal    ${response.json()['status']}    Shipped

Update Order By ID As User
    [Documentation]    Verify updating an existing order fails as a normal user.
    [Tags]    orders
    ${headers}=    Set up Normal user token
    ${data}=    Create Dictionary    status=Cancelled
    ${response}=    PUT    ${BASE_URL_ORDERS}/1    headers=${headers}    json=${data}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403

Delete Order By ID As Admin
    [Documentation]    Verify deleting an order by ID is successful as admin.
    [Tags]    orders
    ${headers}=    Set up Admin token
    ${response}=    DELETE    ${BASE_URL_ORDERS}/2    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Contain    ${response.json()['message']}    deleted successfully

Delete Order By Non - Existent ID As Admin
    [Documentation]    Verify deleting an order by Non - Existent ID is successful as admin.
    [Tags]    orders
    ${headers}=    Set up Admin token
    ${response}=    DELETE    ${BASE_URL_ORDERS}/101    headers=${headers}    expected_status=anything
    Should Be Equal As Integers    ${response.status_code}    404

Delete Order By ID As User
    [Documentation]    Verify deleting an order by ID fails as a normal user.
    [Tags]    orders
    ${headers}=    Set up Normal user token
    ${response}=    DELETE    ${BASE_URL_ORDERS}/1    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    403
