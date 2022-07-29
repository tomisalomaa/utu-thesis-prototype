*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         RequestsLibrary
Library         ExcelLibrary
Library           ../libraries/MyLibrary.py
Resource        ${RESOURCES_DIR}common_keywords.resource
# Creating the report template should be moved as a separate RPA process,
# not be part of the suite setup
Suite Setup     Initiate Assessment Support  ${RESULTS_DIR}
#Suite Teardown  Clean Subject Folders  ${TEST_SUBJECT_DIR}
# exceling alustaminen ja käsittely -- muutoin kuin tulosten päivittäminen -- tulisi tehdä erillisessä automaatiossa
# Test Setup
# Test Teardown

*** Variables ***
${RESOURCES_DIR}  ${CURDIR}${/}..${/}resources${/}
${SUBMISSIONS_DIR}  ${CURDIR}${/}..${/}data${/}submissions${/}
${TEST_SUBJECT_DIR}  ${CURDIR}${/}..${/}data${/}test-subjects${/}
${RESULTS_DIR}  ${CURDIR}${/}..${/}results${/}
${STUDENT_ID}  studentID
${STUDENT_REPORT_ROW}  ${4}
${HTML_FILE}  na
${CSS_FILE}  na

# Here are test cases
*** Test Cases ***
E0-T1-1: Verify Html Anatomy
  [Documentation]  Submission includes a valid html index page.
  ...  Validity is determined by verifying the following contents:
  ...  - Doctype declaration as html
  ...  - Contains <html></html> element
  ...  - Html element contains <head></head> element within
  ...  - Html element contains <body></body> element within
  ...  Passing this assessment is mandatory for scoring in E0.
  [Tags]  ex0  e0t1  full
  
  # The first keyword should be part of the record automation RPA
  Insert Submission Id To Results Summary Sheet  ${STUDENT_REPORT_ROW}  ${STUDENT_ID}
  # Search submitted material for a html index file
  ${html_file}  Search Local HTML Main Page Location  ${TEST_SUBJECT_DIR}
  Should Not Be Empty  ${html_file}
  # Check source code for elements: html, head, body
  ${html_element}  Find Element From Html  ${html_file}  html
  Should Not Be Empty  ${html_element}
  ${head_element}  Find Element From Html  ${html_file}  head
  Should Not Be Empty  ${html_element}
  ${body_element}  Find Element From Html  ${html_file}  body
  Should Not Be Empty  ${body_element}
  # Check for doctype declaration
  ${doctype}  Search Doctype From Html  ${html_file}
  Should Be Equal  ${doctype}[0]  html
  # Open a browser session with the static html page
  New Page  file://${html_file}
  # Take a screenshot of the page for records and added transparency / visibility
  Take Screenshot  filename=${STUDENT_ID}
  # With above steps the test case verifies that the file could function as a valid
  # static page when viewed on a browser.
  Close Page
  Set Global Variable  ${HTML_FILE}  ${html_file}
  # Because html parsers correct a lot of the tag related mistakes by "filling in the blanks",
  # further testing needs to be on the raw text input for proper feedback

E0-T1-2: Page contains a valid anchor element
  [Documentation]  Page should have at least one anchor elment with a href attribute.
  ...  The requirements for href are not set; the href attribute can be even
  ...  declared empty (href="") which by w3 specification is a valid href pointing
  ...  to the document itself.
  ...  Requirements do not place assessment burden on whether the links are broken
  ...  or not or which types of links are created and thus no such assessments
  ...  are included in this test case for functionality.
  [Tags]  ex0  e0t1  full

  # Find anchor elements and their href attributes from source
  ${anchor_href_data}  Find Elements With Attribute  ${HTML_FILE}  a  href
  # Verify at least one anchor element with a href attribute is found
  Should Not Be Empty  ${anchor_href_data}

E0-T1-3: Page contains a valid table element
  [Documentation]  Page has at least one table element that contains proper child elements.
  ...  The hierarchy of table elements is considered to be:
  ...
  ...  1) <table> encapsulates all the table child-elements
  ...  2) <caption> is directly under <table> 
  ...  2) <colgroup> is directly under <table>
  ...  2) <thead> is directly under <table>
  ...  2) <tbody> is directly under <table> and encapsulates <tr> elements
  ...  3) <tr> is directly under <tbody> and encapsulates <th> and <td> elements
  ...  4) <th> is directly under <tr>
  ...  4) <td> is directly under <tr>
  ...  2) <tfoot> is directly under <table>
  ...
  ...  All elements need not be included within a table but if they are
  ...  then the relation between these elements should be as presented.
  ...  If <tbody> is not used then <tr> can be used directly under <table>.
  [Tags]  ex0  e0t1  full

  &{verified_table_results}  Create Dictionary  pass=${0}  fail=${0}
  # Find table elements from the raw html file
  ${table_elements}  Find Elements From Raw Source  ${html_file}  table
  # Validate table hierarchy of each table
  FOR  ${table}  IN  @{table_elements}
    @{elements}  Split String  ${table}  ${SPACE}
    &{relations}  Parent Child Relations From List  ${elements}
    ${verification_result}  Run Keyword And Return Status
    ...  Verify Table Element Hierarchy  ${relations}
    IF  ${verification_result}
      ${verified_table_results['pass']}  Evaluate  ${verified_table_results['pass']} + 1
    ELSE
      ${verified_table_results['fail']}  Evaluate  ${verified_table_results['fail']} + 1
    END
  END
  # Verify at least one table passed the structure test.
  # Allow failing but create a warning as this test only adds to score.
  Run Keyword And Warn On Failure
  ...  Should Be True  ${verified_table_results['pass']} > 0

E0-T1-4: Page contains a valid list element
  [Documentation]  Page has at least one list element that contains proper child elements.
  ...  Lists in html can be defined as <ul>, <menu> (semantic alternative to <ul>) or <ol>.
  ...  Approved direct children for the mentioned list elements are:
  ...  <li>, <script>, <template>
  ...  A list needs to contain at least one or more of these child elements.
  [Tags]  ex0  e0t1  full

  &{verified_list_results}  Create Dictionary  pass=${0}  fail=${0}
  ${ul_elements}  Find Elements From Raw Source  ${html_file}  ul
  ${ol_elements}  Find Elements From Raw Source  ${html_file}  ol
  ${menu_elements}  Find Elements From Raw Source  ${html_file}  menu
  FOR  ${list}  IN  @{ul_elements}
    ${verification_result}  Verify List Element Hierarchy  ${list}
    IF  ${verification_result}
      ${verified_list_results['pass']}  Evaluate  ${verified_list_results['pass']} + 1
    ELSE
      ${verified_list_results['fail']}  Evaluate  ${verified_list_results['fail']} + 1
    END
  END
  FOR  ${list}  IN  @{ol_elements}
    ${verification_result}  Verify List Element Hierarchy  ${list}
    IF  ${verification_result}
      ${verified_list_results['pass']}  Evaluate  ${verified_list_results['pass']} + 1
    ELSE
      ${verified_list_results['fail']}  Evaluate  ${verified_list_results['fail']} + 1
    END
  END
  FOR  ${list}  IN  @{menu_elements}
    ${verification_result}  Verify List Element Hierarchy  ${list}
    IF  ${verification_result}
      ${verified_list_results['pass']}  Evaluate  ${verified_list_results['pass']} + 1
    ELSE
      ${verified_list_results['fail']}  Evaluate  ${verified_list_results['fail']} + 1
    END
  END
  Run Keyword And Warn On Failure
  ...  Should Be True  ${verified_list_results['pass']} > 0

E0-T1-5: Page contains a valid image element
  [Documentation]  Page has at least one img element with content included.
  ...  Element is verifiably correct if it contains the src attribute
  ...  with a non-broken value.
  ...  This test case does not require verifying from a raw file:
  ...  1) There is no need to check for hierarchies or element relations.
  ...  2) If the test object is missing src property or its contents,
  ...     it will be caught all the same as a broken image even when
  ...     html parsers are used.
  [Tags]  ex0  e0t1  full

  &{verified_img_results}  Create Dictionary  pass=${0}  fail=${0}
  New Page  ${HTML_FILE}
  ${img_elements}  Get Elements  xpath=//img
  FOR  ${img}  IN  @{img_elements}
    ${src_attr}  Get Attribute  ${img}  src
    ${img_contains_path}  Check If URL Contains Path  ${src_attr}
    IF  not ${img_contains_path}
      ${src_attr}  Append Path To File Found From Index Html  ${src_attr}
    END
    ${img_is_local}  Run Keyword And Return Status
    ...  File Should Exist  ${src_attr}
    IF  '${img_is_local}' == 'False'
      ${response}  Get Status Of Web Source  ${src_attr}
      IF  ${response}
        ${verified_img_results['pass']}  Evaluate  ${verified_img_results['pass']} + 1
      END
    ELSE
      ${verified_img_results['fail']}  Evaluate  ${verified_img_results['fail']} + 1
    END
  END
  Close Page
  Run Keyword And Warn On Failure
  ...  Should Be True  ${verified_img_results['pass']} > 0

E0-T1-6: Page contains a form with input elements
  [Documentation]  Page has at least one form element containing input elements.
  ...  Action attribute need not be defined.
  [Tags]  ex0  e0t1  full

  &{verified_form_inputs}  Create Dictionary  pass=${0}  fail=${0}
  @{allowed_input_types}  Create List
  ...  button  checkbox  color  date  datetime-local
  ...  email  file  hidden  image  month
  ...  number  password  radio  range  reset
  ...  search  submit  tel  text  time
  ...  url  week
  New Page  ${HTML_FILE}
  ${form_input_elements}  Get Elements  xpath=//form//input
  FOR  ${input}  IN  @{form_input_elements}
    ${input_type}  Get Attribute  ${input}  type
    ${status}  Run Keyword And Return Status
    ...  Should Contain Any  ${input_type}  @{allowed_input_types}
    IF  ${status}
      ${verified_form_inputs['pass']}  Evaluate  ${verified_form_inputs['pass']} + 1
    ELSE
      ${verified_form_inputs['fail']}  Evaluate  ${verified_form_inputs['fail']} + 1
    END
  END
  Close Page
  Run Keyword And Warn On Failure
    ...  Should Be True  ${verified_form_inputs['pass']} > 0

E0-T2-1: CSS file exists and it is referred in the index html file
  [Documentation]
  [Tags]  ex0  e0t2  full

  ${css_file}  Search File With Extension  ${TEST_SUBJECT_DIR}  css
  Should Be Equal  1  0

E0-T2-2: Hover style defined
  [Documentation]
  [Tags]  ex0  e0t2  full

  Should Be Equal  1  0


*** Keywords ***
Verify Table Element Hierarchy
  [Arguments]  ${parent_child_dict}
  FOR  ${relations}  IN  &{parent_child_dict}
    IF  '${relations}[0]' == '<table>'
      Should Not Contain  ${relations}[1]  <table>
    ELSE IF  '${relations}[0]' == '<caption>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <tr>  <th>  <td>  <tfoot>
    ELSE IF  '${relations}[0]' == '<colgroup>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <tr>  <th>  <td>  <tfoot>
    ELSE IF  '${relations}[0]' == '<thead>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <td>  <th>  <tfoot>
      Should Contain  ${relations}[1]  <tr>
    ELSE IF  '${relations}[0]' == '<tbody>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <tfoot>
    ELSE IF  '${relations}[0]' == '<tr>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>
    ELSE IF  '${relations}[0]' == '<th>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <tr>
    ELSE IF  '${relations}[0]' == '<td>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <tr>
    ELSE IF  '${relations}[0]' == '<tfoot>'
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <td>  <th>  <tfoot>
      Should Contain  ${relations}[1]  <tr>
    ELSE
      Should Not Contain Any  ${relations}[1]  <table>  <caption>  <colgroup>  <thead>  <tbody>  <tr>  <th>  <td>  <tfoot>
    END
  END

Verify List Element Hierarchy
  [Arguments]  ${list_elements}
  Log  ${list_elements}
  @{elements}  Split String  ${list_elements}  ${SPACE}
  &{relations}  Parent Child Relations From List  ${elements}
  FOR  ${list}  IN  @{elements}
    ${verification_result}  Run Keyword And Return Status
    ...  Verify List Item Found  ${relations}
  END
  [Return]  ${verification_result}

Verify List Item Found
  [Arguments]  ${parent_child_dict}
  FOR  ${relations}  IN  &{parent_child_dict}
    IF  ('${relations}[0]' == '<ul>' or '${relations}[0]' == '<ol>' or '${relations}[0]' == '<menu>')
      FOR  ${item}  IN  @{relations}[1]
        Should Contain Any  ${item}  <li>  <script>  <template>
      END
    END
  END

Check If URL Contains Path
  [Arguments]  ${src}
  ${img_contains_path}  Get Regexp Matches  ${src}  \.\/|[a-z0-9]\/[a-z0-9]
  [Return]  ${img_contains_path}

Append Path To File Found From Index Html
  [Arguments]  ${src}
  ${index_file_loc}  ${index_file}  Split String From Right  ${HTML_FILE}  ${/}  max_split=1
  ${src}  Set Variable  ${index_file_loc}${/}${src}
  [Return]  ${src}

Get Status Of Web Source
  [Arguments]  ${src}
  ${url_protocol}  Get Regexp Matches  ${src}  http:\/\/|https:\/\/
  ${src}  Set Variable If  ${url_protocol}  ${src}  https:\/\/${src}
  ${response}  GET  ${src}
  [Return]  ${response.ok}

Search Local HTML Main Page Location
  [Arguments]  ${submission_dir}
  ${html_file_location}  Search File With Extension  ${submission_dir}  html
  [Return]  ${html_file_location}
