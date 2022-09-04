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
Suite Teardown  Close Page

*** Test Cases ***
E2-T1-2: Exercises Total Number
  [Documentation]  The App displays a total sum of exercises contained in individual
  ...  parts of the course.
  [Tags]  e2t1
  Find Course App File
  ${exercise_numbers}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  exercises\\s*?:\\s*?([0-9]+)[\\s\\S]  1
  ${total_exercises}  Set Variable  ${0}
  FOR  ${number}  IN  @{exercise_numbers}
    ${total_exercises}  Evaluate  ${total_exercises} + ${number}
  END
  ${total_exercises}  Convert To String  ${total_exercises}
  ${page_root_element}  Get Element  id=root
  ${page_root_element_content}  Get Text  ${page_root_element}
  Should Match Regexp  ${page_root_element_content}  ${total_exercises}

E2-T2-5: Initial State Is Fetched From Server
  [Documentation]  Json-server returns a list of entries when accessed on localhost.
  ...  The contents of this list are displayed by the app as initial state.
  [Tags]  e2t2
  Get Element Count  xpath=//*[text() = 'Test Server']  ==  1
  Get Element Count  xpath=//*[text() = '1234567890']  ==  1

E2-T2-1: Prevent Adding Already Existing Name
  [Documentation]  If the directory already includes the name that user tries to add, prevent adding it.
  [Tags]  e2t2
  Get Element Count  xpath=//*[text() = 'Testi Testsson']  ==  0
  Fill Text  (//input)[1]  Testi Testsson
  Fill Text  (//input)[2]  012-3456789
  Click  (//button[@type])[1]
  Get Element Count  xpath=//*[text() = 'Testi Testsson']  ==  1
  Fill Text  (//input)[1]  Testi Testsson
  Fill Text  (//input)[2]  012-3456789
  Click  (//button[@type])[1]
  Get Element Count  xpath=//*[text() = 'Testi Testsson']  ==  1

E2-T2-3: Contact Can Be Deleted
  [Documentation]   Removing entries can happen with the buttons attached to each person entry.
  ...  When the removal takes place, window.confirm method is used to to ask whether the user really
  ...  wants to remove the entry.
  ...  Removal happens by performing a DELETE request corresponding to entry id.
  [Tags]  e2t2
  ${button_count_base}  Get Element Count  xpath=//button
  Click  xpath=(//button)[${button_count_base}]
  ${button_count_current}  Get Element Count  xpath=//button
  Should Not Be Equal  ${button_count_base}  ${button_count_current}
  ${button_count_base}  Set Variable  ${button_count_current}
  DELETE  http://localhost:3001/persons/1
  Reload
  Wait For Elements State  xpath=(//button)[1]  visible
  ${button_count_current}  Get Element Count  xpath=//button
  Should Not Be Equal  ${button_count_base}  ${button_count_current}

*** Keywords ***
Initiate Dynamic Testing
  Log  ${TEST_SUBJECT_DIR}
  New Page  ${REACT_APP_ADDR}
  Handle Future Dialogs  action=accept

Find Course App File
  @{course_js_keywords}  Create List  App  course  parts
  ${course_js_file}  Find Most Recent File Based On Keywords  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  js
  Set Global Variable  ${COURSE_JS_FILE}  ${course_js_file}
  ${course_js_file_contents}  Get File  ${COURSE_JS_FILE}
  Set Global Variable  ${COURSE_JS_FILE_CONTENTS}  ${course_js_file_contents}