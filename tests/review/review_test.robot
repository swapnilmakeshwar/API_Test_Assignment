*** Settings ***
Library           RequestsLibrary
Library    Collections

*** Variables ***
${BASE_URL_AUTH}        http://127.0.0.1:5000/api/v1/auth
${BASE_URL_REVIEWS}   http://127.0.0.1:5000/api/v1/reviews

*** Test Cases ***
Test Retrieve All Reviews
    [Documentation]    Verify that all reviews are retrieved successfully.
    [Tags]    review
    ${response}    Get    ${BASE_URL_REVIEWS}
    Should Be Equal As Numbers    ${response.status_code}    200
    Length Should Be    ${response.json()}    2

Test Retrieve Single Review
    [Documentation]    Verify that a single review is retrieved successfully using a valid review ID.
    [Tags]    review
    ${response}    Get    ${BASE_URL_REVIEWS}/1
    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    review
    Dictionary Should Contain Value    ${response.json()}    Great product!

Test Retrieve Single Review with Invalid Reveiw ID
    [Documentation]    Verify that the system returns an appropriate error for an invalid review ID.
    [Tags]    review
    ${response}    Get    ${BASE_URL_REVIEWS}/1.1    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    404


Test Create New Review
    [Documentation]    Verify that a new review is successfully created with all required fields.
    [Tags]    review
    ${payload}    Create Dictionary    product_id=2    review=Amazing!    rating=5
    ${response}    Post    ${BASE_URL_REVIEWS}    json=${payload}
    Should Be Equal As Numbers    ${response.status_code}    201
    Dictionary Should Contain Key    ${response.json()}    id

Test Create New Review with Missing Mandatory Rating Field
    [Documentation]    Verify that a new review cannot be created if the `rating` field is missing.
    [Tags]    review
    ${payload}    Create Dictionary    product_id=200    review=Amazing!
    ${response}    Post    ${BASE_URL_REVIEWS}    json=${payload}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    400

Test Create New Review with Missing Mandatory review Field
    [Documentation]    Verify that a new review cannot be created if the `review` field is missing.
    [Tags]    review
    ${payload}    Create Dictionary    product_id=200    rating=5
    ${response}    Post    ${BASE_URL_REVIEWS}    json=${payload}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    400 

Test Update Review
    [Documentation]    Verify that a review can be updated with valid data.
    [Tags]    review
    ${payload}    Create Dictionary    review=Just okay    rating=3
    ${response}    Put    ${BASE_URL_REVIEWS}/1    json=${payload}
    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Value    ${response.json()}    Just okay

Test Update Review with random String of more than 100 characters
    [Documentation]    Verify that a review can be updated with a long string of more than 100 characters.
    [Tags]    review
    ${review_value}=    Set Variable    The story in “100 chars” is told in three line stanzas, each containing 100 characters of text. The primary form of
    ${payload}    Create Dictionary    review=${review_value}    rating=3
    ${response}    Put    ${BASE_URL_REVIEWS}/1    json=${payload}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Value    ${response.json()}    ${review_value}

Test Update Review with Non - existent ID
    [Documentation]    Verify that a review cannot be updated if the ID does not exist.
    [Tags]    review
    ${payload}    Create Dictionary    review=Just okay    rating=3
    ${response}    Put    ${BASE_URL_REVIEWS}/100    json=${payload}    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    404


Test Delete Review
    [Documentation]    Verify that a review can be deleted successfully.
    [Tags]    review
    ${response}    Delete    ${BASE_URL_REVIEWS}/2
    Should Be Equal As Numbers    ${response.status_code}    200
    Dictionary Should Contain Value    ${response.json()}    Review with id 2 deleted successfully

Test Delete Review with non existent Review ID
    [Documentation]    Verify that a review cannot be deleted if the ID does not exist.
    [Tags]    review
    ${response}    Delete    ${BASE_URL_REVIEWS}/100    expected_status=anything
    Should Be Equal As Numbers    ${response.status_code}    404
