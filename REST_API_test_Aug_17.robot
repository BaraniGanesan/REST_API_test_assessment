*** Settings ***
Library		RequestsLibrary
Library     Collections
Library     jsonschema
Library     JsonValidator

*** Variables ***
${base_url}		https://gorest.co.in
${auth}    Basic Auth

*** Test Cases ***
TC1_Verify response has pagination
    [Tags]      Functional
    [Documentation]    verifying the GET response has pagination details

    ${session_res_OP}=      Create session and get response     ${base_url}     ${auth}
    Check Response Status       ${session_res_OP}       actual_resp=200
    Verify response has pagination      ${session_res_OP}

#TC2_Verify response has Valid Json Data
#    [Tags]      Functional
#    [Documentation]    verifying the GET response has valid JSON Data
#
#    ${session_res_OP}=      Create session and get response     ${base_url}     ${auth}
#    Check Response Status       ${session_res_OP}       actual_resp=200
#    Verify response has Valid JSON Data      ${session_res_OP}

TC3_Verify Response Data has email address
    [Tags]      Functional
    [Documentation]    verifying the GET response has email address

    ${session_res_OP}=      Create session and get response     ${base_url}     ${auth}
    Check Response Status       ${session_res_OP}       actual_resp=200
    Verify response has email address      ${session_res_OP}

TC_4_Verify all entries on list data have similar attributes
    [Tags]      Functional
    [Documentation]    verifying list elements has similar data

    @{test_attributes_list}=       Create List      1   1   1   1
    ${len}=    Get length    ${test_attributes_list}
    ${count}=   Set Variable   1
    FOR     ${i}    IN RANGE    0    ${len}-1
        ${temp}=    Evaluate    ${i}+1
        Run keyword IF   "${test_attributes_list}[${i}]" != "${test_attributes_list}[${temp}]"   Fail   Values in list are not equal
        ${count}=   Evaluate    ${count}+1
    END
    IF   "${count}" == "${len}"
        Log     All values in list are equal
    END

TC_5_Verify HTTP response codes
    [Tags]      Non-Functional
    [Documentation]    verifying the HTTP response codes
    ${headers}=   Create Dictionary    Authorization=${auth}
    Create Session   url_session    ${base_url}     headers=${headers}
    ${resp}=   GET On Session   url_session     /public/v2/users      expected_status=200
    ${resp}=   GET On Session   url_session     /public/v2/user      expected_status=404
    ${resp}=   POST On Session   url_session     /public/v2/users      expected_status=401

TC_6_Verify REST service without authentication
    [Tags]      Non-Functional
    [Documentation]    verifying REST service without authentication
    ${session_res_OP}=      Create session and get response     ${base_url}     auth=No Auth
    Check Response Status       ${session_res_OP}       actual_resp=200

*** keywords ***
Create session and get response
    [Documentation]    creating a session and retrives responses
    [Arguments]    ${base_url}     ${auth}
    ${headers}=   Create Dictionary    Authorization=${auth}
    Create Session   url_session    ${base_url}     headers=${headers}
    ${get_response}=   GET On Session   url_session     /public/v2/users         ####posts,comments,todos
    [Return]      ${get_response}

Check Response Status
        [Arguments]     ${resp}     ${actual_resp}
        Log     ${resp}
        Status Should Be    ${actual_resp}    ${resp}
        Request Should Be Successful       ${resp}


Verify response has pagination
    [Documentation]    verifying the response has pagination details
    [Arguments]    ${session_res_OP}

    ${OP}=  Get From Dictionary    ${session_res_OP.headers}   x-pagination-pages
    IF  ${OP}
        ${total_pages}=    Get From Dictionary    ${session_res_OP.headers}    x-pagination-pages
        Log     Total number of pages in response is ${total_pages}
        ${current_page}=    Get From Dictionary    ${session_res_OP.headers}    x-pagination-page
        Log     Current page number is ${current_page}
        ${per_page_limit}=    Get From Dictionary    ${session_res_OP.headers}    x-pagination-limit
        Log     Results per page is ${per_page_limit}
        ${total_results}=    Get From Dictionary    ${session_res_OP.headers}    x-pagination-total
        Log     Total number of results ${total_results}
    ELSE
        Fail    There is no pagenation in response
    END

Verify response has Valid JSON Data
    [Documentation]    verifying the response has valid JSON Data
    [Arguments]    ${session_res_OP}

    ${Expected_OP}=  Get From Dictionary    ${session_res_OP.headers}   Content-Type
    should contain      ${Expected_OP}      json
    Log     The Response contains json contents

Verify response has email address
    [Documentation]    verifying the response has users email address
    [Arguments]    ${session_res_OP}

    Log     ${session_res_OP.json()}
    @{users_email_list}=       Create List
    FOR     ${i}   IN RANGE     0    10
        ${OP}=  Set variable    ${session_res_OP.json()}[${i}][email]
        IF  "${OP}" != "${None}"
            Append To List    ${users_email_list}     ${session_res_OP.json()}[${i}][email]
        ELSE
            Log    Email address is not present for user ${session_res_OP.json()}[${i}][name]
        END
    END
    Log     Response has email addresses and those are ${users_email_list}




