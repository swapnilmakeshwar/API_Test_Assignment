*** Settings ***
Library    Collections
Library    RequestsLibrary


*** Variables ***
${BASE_URL_AUTH}        http://127.0.0.1:5000/api/v1/auth


*** Keywords ***
Set up Admin token
    [Documentation]    This Keywords Set up Admin token
    ${login_payload}    Create Dictionary    email=admin@example.com    password=admin123
    ${response}         Post         ${BASE_URL_AUTH}/login    json=${login_payload}
    ${token}            Set Variable         ${response.json()['token']}

    ${headers}          Create Dictionary    Authorization=${token}
    RETURN    ${headers}

Set up Normal user token
    [Documentation]    This Keywords Set up Admin token
    ${login_payload}    Create Dictionary    email=user@example.com    password=user123
    ${response}         Post         ${BASE_URL_AUTH}/login    json=${login_payload}
    ${token}            Set Variable         ${response.json()['token']}

    ${headers}          Create Dictionary    Authorization=${token}
    RETURN    ${headers}

Set up Incorrect Token
    [Documentation]    This Keywords Set up Incorrect Token
    ${headers}=    Create Dictionary    Authorization=incorrect_token
    RETURN    ${headers}