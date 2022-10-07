*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         RequestsLibrary
Library         ${LIBRARIES_DIR}${/}MyLibrary.py
Variables       ${GLOBAL_ROBO_VARIABLES_DIR}${/}common_variables.py
Resource        ${RESOURCES_DIR}${/}common_keywords.resource
Suite Setup     Initiate Dynamic Testing
Suite Teardown  End Dynamic Testing

*** Test Cases ***
E3-T1-4: Contact Can Be Added Using POST
  [Documentation]  A contact entry can be added by performing a POST request to http://localhost:3001/api/persons.
  ...  The POST request contains a json body with name and number values.
  [Tags]  e3t1
  &{test_data_json}  Create Dictionary  name=Testi Testsson  number=0401234567
  POST  ${REACT_SERVER_ADDR}/api/persons/  json=${test_data_json}

E3-T1-2-1: Single Id Request Successful
  [Documentation]  API returns a single directory entry when id is requested, 
  ...  for example GET http://localhost:3001/api/persons/1 returns entry corresponding to entry with id 1.
  [Tags]  e3t1
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  ${ids}  Get Regexp Matches  ${response_string}  id":"(.*?)"|id":([0-9]*?)\\D  1  2
  ${ids}  Flatten To List  ${ids}
  ${names}  Get Regexp Matches  ${response_string}  name":"(.*?)"|nimi":"(.*?)"  1  2
  ${names}  Flatten To List  ${names}
  ${numbers}  Get Regexp Matches  ${response_string}  number":"(.*?)"|numero":"(.*?)"|num":"(.*?)"  1  2  3
  ${numbers}  Flatten To List  ${numbers}
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/${ids}[0]
  ${response_string}  Convert To String  ${response.content}
  Should Match Regexp  ${response_string}  ${ids}[0]
  Should Match Regexp  ${response_string}  ${names}[0]
  Should Match Regexp  ${response_string}  ${numbers}[0]

E3-T1-3: Contact Can Be Deleted Using DELETE
  [Documentation]  A contact entry can be removed with a DELETE request to http://localhost:3001/api/persons/*id*.
  [Tags]  e3t1
  Take Screenshot
  ${ids}  Get All Ids From Database
  ${id_amount_before}  Get Length  ${ids}
  ${id_amount_expected_after_delete}  Evaluate  ${id_amount_before}-1
  Set Global Variable  ${FAIL_SINGLE_ID_REQUEST}  ${ids}[0]
  DELETE  ${REACT_SERVER_ADDR}/api/persons/${ids}[0]
  Take Screenshot
  ${ids}  Get All Ids From Database
  ${id_amount_after}  Get Length  ${ids}
  Should Be Equal As Integers  ${id_amount_expected_after_delete}  ${id_amount_after}

E3-T1-2-2: Single Id Request Unsuccessful
  [Documentation]  If id is not a valid directory entry, then the respond is an appropriate status code 404.
  [Tags]  e3t1
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/${FAIL_SINGLE_ID_REQUEST}  expected_status=Anything
  Should Contain Any  [${response.status_code}]  404  400

E3-T1-5-1: Entry Adding Error Handling When Name exists UI
  [Documentation]  The request should not be accepted if 
  ...  1) name or number is missing from the request;
  ...  2) the name to be added already exists in the directory.
  [Tags]  e3t1
  # Get initial state of entries
  ${response}  Get All Ids From Database
  ${entry_amount}  Get Length  ${response}
  Go To  ${REACT_SERVER_ADDR}
  Take Screenshot
  # Fill in details of a new entry and add
  Attempt To Add User  User Interface  12345
  # Check that the amount of entries changes
  Take Screenshot
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Not Be Equal  ${new_entry_amount}  ${entry_amount}
  ${entry_amount}  Set Variable  ${new_entry_amount}
  # Make sure to input same info and try to add the person again
  Attempt To Add User  User Interface  12345
  # Check that the amount of entries has remained the same
  Take Screenshot
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without name
  Attempt To Add User  ${EMPTY}  12345
  Take Screenshot
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without number
  Attempt To Add User  User Interface  ${EMPTY}
  Take Screenshot
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without any info
  Attempt To Add User  ${EMPTY}  ${EMPTY}
  Take Screenshot
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}

E3-T1-5-2: Entry Adding Error Handling When Name Exists API
  [Documentation]  The request should not be accepted if 
  ...  1) name or number is missing from the request;
  ...  2) the name to be added already exists in the directory.
  [Tags]  e3t1
  # Get initial state of entries
  Take Screenshot
  ${response}  Get All Ids From Database
  ${entry_amount}  Get Length  ${response}
  &{test_data_json}  Create Dictionary  name=API Addition  number=12345
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  # Check that the amount of entries changes
  Take Screenshot
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Not Be Equal  ${new_entry_amount}  ${entry_amount}
  ${entry_amount}  Set Variable  ${new_entry_amount}
  # Make sure to input same info and try to add the person again
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  # Check that the amount of entries has remained the same
  ${response}  Get All Ids From Database
  Take Screenshot
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without name
  &{test_data_json}  Create Dictionary  name=${EMPTY}  number=12345
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  ${response}  Get All Ids From Database
  Take Screenshot
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without number
  &{test_data_json}  Create Dictionary  name=API Addition  number=${EMPTY}
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  ${response}  Get All Ids From Database
  Take Screenshot
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without any info
  &{test_data_json}  Create Dictionary  name=${EMPTY}  number=${EMPTY}
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  ${response}  Get All Ids From Database
  Take Screenshot
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}

E3-T1-1: Json Array Is Returned From A Localhost Server
  [Documentation]  Address http://localhost:3001/api/persons returns phone directory entries stored in array.
  [Tags]  e3t1
  Take Screenshot
  &{test_data_json}  Create Dictionary  name=Tauno Testaaja  number=0501234567
  POST  ${REACT_SERVER_ADDR}/api/persons/  json=${test_data_json}
  Take Screenshot
  &{test_data_json}  Create Dictionary  name=Tiina Testeri  number=0901234567
  POST  ${REACT_SERVER_ADDR}/api/persons/  json=${test_data_json}
  Take Screenshot
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  Should Match Regexp  ${response_string}  \\[{.*?}\\]
  Should Match Regexp  ${response_string}  "name":".*?"|"nimi":".*?"
  Should Match Regexp  ${response_string}  "number":".*?"|"numero":".*?"|"num":".*?"
  Should Match Regexp  ${response_string}  "id":".*?"|"id":.*?

*** Keywords ***
Initiate Dynamic Testing
  Log  ${TEST_SUBJECT_DIR}
  New Page  ${REACT_SERVER_ADDR}
  Handle Future Dialogs  action=accept

End Dynamic Testing
  Close Page
  Run Keyword If All Tests Passed
  ...  Delete All Entries

Delete All Entries
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  ${ids}  Get Regexp Matches  ${response_string}  id":"(.*?)"|id":([0-9]*?)\\D  1  2
  ${ids}  Flatten To List  ${ids}
  FOR  ${id}  IN  @{ids}
    DELETE  ${REACT_SERVER_ADDR}/api/persons/${id}
  END

Get All Ids From Database
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  ${entries}  Get Regexp Matches  ${response_string}  id":"(.*?)"|id":([0-9]*?)\\D  1  2
  ${entries}  Flatten To List  ${entries}
  [Return]  ${entries}

Attempt To Add User
  [Arguments]  ${name}  ${number}
  Clear Text  xpath=(//input)[1]
  Clear Text  xpath=(//input)[2]
  Fill Text  xpath=(//input)[1]  ${name}
  Fill Text  xpath=(//input)[2]  ${number}
  Click  xpath=(//button)[1]

Flatten To List
  [Arguments]  ${input}
  @{to_be_flat_list}  Create List
  @{return_flat_list}  Create List
  FOR  ${item}  IN  @{input}
    @{list_item}  Convert To List  ${item}
    Append To List  ${to_be_flat_list}  ${list_item}
  END
  ${to_be_flat_list}  Evaluate  [item for sublist in ${to_be_flat_list} for item in (sublist if isinstance(sublist, list) else [sublist])]
  FOR  ${item}  IN  @{to_be_flat_list}
    IF  '${item}' != 'None'
      Append To List  ${return_flat_list}  ${item}
    END
  END
  Log  ${return_flat_list}
  [Return]  ${return_flat_list}