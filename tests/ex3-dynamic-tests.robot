*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         RequestsLibrary
Library         ..${/}libraries${/}MyLibrary.py
Variables       ..${/}variables${/}common_variables.py
Resource        ..${/}resources${/}common_keywords.resource
Suite Setup     Initiate Dynamic Testing
Suite Teardown  End Dynamic Testing

*** Test Cases ***
E3-T1-4: Contact Can Be Added Using POST
  [Documentation]  A contact entry can be added by performing a POST request to http://localhost:3001/api/persons.
  ...  The POST request contains a json body with name and number values.
  [Tags]  e3t1
  
  &{test_data_json}  Create Dictionary  name=Testi Testsson  number=0401234567
  POST  ${REACT_SERVER_ADDR}/api/persons/  json=${test_data_json}

E3-T1-1: Json Array Is Returned From A Localhost Server
  [Documentation]  Address http://localhost:3001/api/persons returns phone directory entries stored in array.
  [Tags]  e3t1
  
  &{test_data_json}  Create Dictionary  name=Tauno Testaaja  number=0501234567
  POST  ${REACT_SERVER_ADDR}/api/persons/  json=${test_data_json}
  &{test_data_json}  Create Dictionary  name=Tiina Testeri  number=0901234567
  POST  ${REACT_SERVER_ADDR}/api/persons/  json=${test_data_json}
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  Should Match Regexp  ${response_string}  \\[{.*?}\\]
  Should Match Regexp  ${response_string}  "name":".*?"|"nimi":".*?"
  Should Match Regexp  ${response_string}  "number":".*?"|"numero":".*?"|"num":".*?"
  Should Match Regexp  ${response_string}  "id":".*?"|"id":.*?

E3-T1-2: Single Id Can Be Requested
  [Documentation]  API returns a single directory entry when id is requested, 
  ...  for example GET http://localhost:3001/api/persons/1 returns entry corresponding to entry with id 1.
  ...  If id is not a valid directory entry, then the respond is an appropriate status code 404.
  [Tags]  e3t1

  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  ${ids}  Get Regexp Matches  ${response_string}  id":"(.*?)"|id":([0-9]*?)\\D  1
  ${names}  Get Regexp Matches  ${response_string}  name":"(.*?)"|nimi":"(.*?)"  1
  ${numbers}  Get Regexp Matches  ${response_string}  number":"(.*?)"|numero":"(.*?)"|num":"(.*?)"  1
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/${ids}[0]
  ${response_string}  Convert To String  ${response.content}
  Should Match Regexp  ${response_string}  ${ids}[0]
  Should Match Regexp  ${response_string}  ${names}[0]
  Should Match Regexp  ${response_string}  ${numbers}[0]
  DELETE  ${REACT_SERVER_ADDR}/api/persons/${ids}[0]
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/${ids}[0]  expected_status=Anything
  Should Contain Any  ${response.status}  404  400

E3-T1-3: Contact Can Be Deleted Using DELETE
  [Documentation]  A contact entry can be removed with a DELETE request to http://localhost:3001/api/persons/*id*.
  [Tags]  e3t1
  
  ${ids}  Get All Ids From Database
  ${id_amount_before}  Get Length  ${ids}
  ${id_amount_expected_after_delete}  Evaluate  ${id_amount_before}-1
  DELETE  ${REACT_SERVER_ADDR}/api/persons/${ids}[0]
  ${ids}  Get All Ids From Database
  ${id_amount_after}  Get Length  ${ids}
  Should Be Equal As Integers  ${id_amount_expected_after_delete}  ${id_amount_after}

E3-T1-5-1: Entry Adding Error Handling UI
  [Documentation]  The request should not be accepted if 
  ...  1) name or number is missing from the request;
  ...  2) the name to be added already exists in the directory.
  [Tags]  e3t1

  # Get initial state of entries
  ${response}  Get All Ids From Database
  ${entry_amount}  Get Length  ${response}
  # Fill in details of a new entry and add
  Attempt To Add User  User Interface  12345
  # Check that the amount of entries changes
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Not Be Equal  ${new_entry_amount}  ${entry_amount}
  ${entry_amount}  Set Variable  ${new_entry_amount}
  # Make sure to input same info and try to add the person again
  Attempt To Add User  User Interface  12345
  # Check that the amount of entries has remained the same
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without name
  Attempt To Add User  ${EMPTY}  12345
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without number
  Attempt To Add User  User Interface  ${EMPTY}
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without any info
  Attempt To Add User  ${EMPTY}  ${EMPTY}
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}

E3-T1-5-2: Entry Adding Error Handling API
  [Documentation]  The request should not be accepted if 
  ...  1) name or number is missing from the request;
  ...  2) the name to be added already exists in the directory.
  [Tags]  e3t1

  # Get initial state of entries
  ${response}  Get All Ids From Database
  ${entry_amount}  Get Length  ${response}
  &{test_data_json}  Create Dictionary  name=API Addition  number=12345
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  # Check that the amount of entries changes
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Not Be Equal  ${new_entry_amount}  ${entry_amount}
  ${entry_amount}  Set Variable  ${new_entry_amount}
  # Make sure to input same info and try to add the person again
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  # Check that the amount of entries has remained the same
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without name
  &{test_data_json}  Create Dictionary  name=${EMPTY}  number=12345
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without number
  &{test_data_json}  Create Dictionary  name=API Addition  number=${EMPTY}
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}
  # Try adding without any info
  &{test_data_json}  Create Dictionary  name=${EMPTY}  number=${EMPTY}
  POST  ${REACT_SERVER_ADDR}/api/persons  json=${test_data_json}
  ${response}  Get All Ids From Database
  ${new_entry_amount}  Get Length  ${response}
  Should Be Equal  ${new_entry_amount}  ${entry_amount}

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
  ${ids}  Get Regexp Matches  ${response_string}  id":"(.*?)"|id":([0-9]*?)\\D  1
  FOR  ${id}  IN  @{ids}
    DELETE  ${REACT_SERVER_ADDR}/api/persons/${id}
  END

Get All Ids From Database
  ${response}  GET  ${REACT_SERVER_ADDR}/api/persons/
  ${response_string}  Convert To String  ${response.content}
  ${entries}  Get Regexp Matches  ${response_string}  id":"(.*?)"|id":([0-9]*?)\\D  1
  [Return]  ${entries}

Attempt To Add User
  [Arguments]  ${name}  ${number}
  Clear Text  xpath=(//input)[1]
  Clear Text  xpath=(//input)[2]
  Fill Text  xpath=(//input)[1]  ${name}
  Fill Text  xpath=(//input)[2]  ${number}
  Click  xpath=(//button)[1]