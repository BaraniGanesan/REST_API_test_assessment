*** Settings ***
Library		RequestsLibrary
Library     Collections
Library     jsonschema
Library    OperatingSystem

*** Variables ***
${base_url}		https://gorest.co.in
${auth}    Basic Auth
${Bearer_token}     Bearer 0ece194d2ba317043dec8744a3ae769a1681ab94226c47d13e7b56c540eda274

*** Test Cases ***
TC1_Verify response has pagination
    [Tags]      Functional
    [Documentation]    verifying the GET response has pagination details

    ${session_res_OP}=      Create session and get response     ${base_url}     ${auth}
    Check Response Status       ${session_res_OP}       actual_resp=200
    Verify response has pagination      ${session_res_OP}

TC2_Verify response has Valid Json Data
    [Tags]      Functional
    [Documentation]    verifying the GET response has valid JSON Data

    ${session_res_OP}=      Create session and get response     ${base_url}     ${auth}
    Check Response Status       ${session_res_OP}       actual_resp=200
    ${actual_json}=     Set Variable    ${session_res_OP.json()}
    Log     ${actual_json}
    ${json_example}=    OperatingSystem.Get File   C:\\Users\\27646\\PycharmProjects\\Project_test_robot\\json_schema_format.json
    ${format_schema_json}    evaluate    json.loads('''${json_example}''')    json
    Log     ${format_schema_json}
    jsonschema.Validate    instance=${actual_json}   schema=${format_schema_json}


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
    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    ${body}=       Create Dictionary        name=Barani1         email=barani1.g@example.com      gender=female   status=active
    ${resp}=   POST On Session     url_session    /public/v2/users     data=${body}     headers=${headers}    expected_status=422


TC_6_Verify REST service without authentication
    [Tags]      Non-Functional
    [Documentation]    verifying REST service without authentication
    ${session_res_OP}=      Create session and get response     ${base_url}     auth=No Auth
    Check Response Status       ${session_res_OP}       actual_resp=200

TC_7_Verify Non-SSL Rest endpoint behaviour
    [Tags]      Functional
    [Documentation]    using parameter verify=False to disable ssl warnings

    ${headers}=   Create Dictionary    Authorization=${auth}
    Create Session   url_session    ${base_url}     headers=${headers}    verify=False
    ${get_response}=   GET On Session   url_session     /public/v2/users
    Check Response Status       ${get_response}       actual_resp=200

TC_8_Create new user
    [Tags]      Functional
    [Documentation]    creating a new user

    Create Session   url_session    ${base_url}
    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    ${body}=       Create Dictionary        name=Barani555         email=barani555.g@example.com      gender=female   status=active
    ${post_response}=   POST On Session     url_session    /public/v2/users     data=${body}     headers=${headers}
    Check Response Status       ${post_response}       actual_resp=201
    Log     ${post_response.json()}
    ${id}=    Set Variable    ${post_response.json()}[id]
    Set Suite Variable   ${id}
    ${get_response}=   GET On Session   url_session     /public/v2/users/${id}    headers=${headers}

TC_9_Trying to create different user with same email id created for another user
    [Tags]      Non-Functional
    [Documentation]    using same email id for different user should fail and return error 422

    Create Session   url_session    ${base_url}
    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    ${body}=       Create Dictionary        name=dummy_user    email=barani555.g@example.com      gender=male   status=inactive
    ${post_response}=   POST On Session    url_session    /public/v2/users    data=${body}    headers=${headers}   expected_status=422

TC_10_Update whole resource
    [Tags]      Functional
    [Documentation]    Using PUT to modify the whole resource

    Create Session   url_session    ${base_url}
    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    ${body}=       Create Dictionary        name=test666         email=test666.g@example.com      gender=male   status=inactive
    ${put_response}=   PUT On Session     url_session    /public/v2/users/${id}     data=${body}     headers=${headers}
    Check Response Status       ${put_response}       actual_resp=200
    ${get_response}=   GET On Session   url_session     /public/v2/users/${id}    headers=${headers}


TC_11_Update partial resource
    [Tags]      Functional
    [Documentation]    Using PATCH to modify the partial resource

    Create Session   url_session    ${base_url}
    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    ${body}=       Create Dictionary        email=test777.g@example.com
    ${put_response}=   PATCH On Session     url_session    /public/v2/users/${id}     data=${body}     headers=${headers}
    Check Response Status       ${put_response}       actual_resp=200
    ${get_response}=   GET On Session   url_session     /public/v2/users/${id}   headers=${headers}

TC_12_Delete user
    [Tags]      Functional
    [Documentation]    deleting the user created

    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    Create Session   url_session    ${base_url}    ${headers}
    ${del_resp}=   DELETE On Session     url_session    /public/v2/users/${id}     expected_status=204

TC_13_Trying to access deleted user
    [Tags]      Non-Functional
    [Documentation]    Trying to get the deleted user should given error 404

    ${headers}=   Create Dictionary    Authorization=${Bearer_token}
    Create Session   url_session    ${base_url}    ${headers}
    ${get_response}=   GET On Session   url_session     /public/v2/users/${id}    headers=${headers}    expected_status=404

*** keywords ***
Create session and get response
    [Documentation]    creating a session and retrives responses
    [Arguments]    ${base_url}     ${auth}

    ${headers}=   Create Dictionary    Authorization=${auth}
    Create Session   url_session    ${base_url}     headers=${headers}
    ${get_response}=   GET On Session   url_session     /public/v2/users
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







