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
  #######################################################
  # FIX FETCHING OF TESTABLE MATERIAL (HTML AND CSS FILES)
  # TO BE PART OF THE SUITE SETUP!
  # THEN REMOVE THE LOGIC FOR SETTING GLOBAL HTML VARIABLES
  #######################################################
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
      ELSE
        ${verified_img_results['fail']}  Evaluate  ${verified_img_results['fail']} + 1
      END
    ELSE
      ${verified_img_results['pass']}  Evaluate  ${verified_img_results['pass']} + 1
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
  [Documentation]    Search for a css file within the submitted materials.
  ...    Verify it is being referred inside the header section of index html file.
  [Tags]  ex0  e0t2  full

  # FIX FETCHING OF TESTABLE MATERIAL (HTML AND CSS FILES)
  # TO BE PART OF THE SUITE SETUP!
  # THEN REMOVE THE COMMENT-SURROUNDED PART BELOW
  #######################################################
  ${css_file}  Search File With Extension  ${TEST_SUBJECT_DIR}  css
  Set Global Variable  ${CSS_FILE}  ${css_file}
  #######################################################
  ${css_file_dir}  ${css_file_name}  Split String From Right  ${css_file}  ${/}  max_split=1
  ${head_element}  Find Element From Html  ${HTML_FILE}  head
  ${head_children}  Find Immediate Child Elements  ${head_element}
  FOR  ${child}  IN  @{head_children}
    IF  '${child.name}' == 'link'
      ${rel_content}  Set Variable  ${child}[rel]
      ${href_content}  Set Variable  ${child}[href]
      ${rel_verified}  Run Keyword And Warn On Failure
      ...  Run Keyword And Return Status
      ...  Should Be Equal As Strings  ${rel_content}[0]  stylesheet
      ${href_verified}  Run Keyword And Warn On Failure
      ...  Run Keyword And Return Status
      ...  Should Contain  ${href_content}  ${css_file_name}
    END
  END
  IF  ${rel_verified} and ${href_verified}
    Log  Stylesheet referred to correctly from html
  ELSE
    Log  Stylesheet incorrectly referred to from html
  END

E0-T2-2: Hover style defined
  [Documentation]  Hover styling for an anchor element is verifiably implemented.
  ...  Includes assumptions:
  ...  1) Styling needs to refer or be used on an anchor element;
  ...     simply defining hover style is not enough.
  ...  2) Most cases to test will follow study material and the referred Mozilla tutorial;
  ...     most popular ways to define the style will be a:hover and a.class-ref:hover.
  [Tags]  ex0  e0t2  full

  ${css_file_contents}  Get File  ${CSS_FILE}
  ${hover_styles}  Get Regexp Matches  ${css_file_contents}  \s*?a:hover|\s*?a\..*?:hover
  ${ahover_is_in_list}  Evaluate  'a:hover' in ${hover_styles}
  IF  not ${ahover_is_in_list}
    ${class_name}  Get Regexp Matches  ${style}  \.(.*?):  1
    ${class_name}  Strip String  ${class_name}[0]  characters=.
    ${class_matches}  Find Elements By Class  ${HTML_FILE}  a  ${class_name}
    Run Keyword And Warn On Failure
    ...  Should Be True  ${class_matches}
  ELSE
    Run Keyword And Warn On Failure
    ...  Should Be True  ${hover_styles}
  END

E0-T2-3: List and table styles are defined
  [Documentation]  Styles are defined for lists and tables.
  ...  Additionally the tasker requires the use of classes and
  ...  ids to define styles; past assessments have, however,
  ...  given full scores even if tables and lists specifically
  ...  do not use class or id declarations to define their styles.
  ...  Thus checking for the use of styles and classes for styling
  ...  is a test case of it's own.
  ...  Use of these declarations still need to be checked in scope of
  ...  tables and lists here because there is a possibility they are
  ...  used instead of generally styling the elements.
  [Tags]  ex0  e0t2  full

  @{table_ids}  Create List
  @{table_classes}  Create List
  @{list_ids}  Create List
  @{list_classes}  Create List
  # Gather table elements from html file
  ${table_elements}  Find Elements From Html  ${HTML_FILE}  table
  # Store id and class references
  FOR  ${elem}  IN  @{table_elements}
    @{elem_items}  Create List  ${elem.get('id')}
    FOR  ${item}  IN  @{elem_items}
      IF  '${item}' != 'None'
        Append To List  ${table_ids}  ${item}
      END
    END
    @{elem_items}  Create List  ${elem.get('class')}
    FOR  ${item}  IN  @{elem_items}
      IF  ${item} != None
        Append To List  ${table_classes}  ${item}[0]
      END
    END
  END
  # Gather list elements from html file
  ${ul_list_elements}  Find Elements From Html  ${HTML_FILE}  ul
  ${ol_list_elements}  Find Elements From Html  ${HTML_FILE}  ol
  ${menu_list_elements}  Find Elements From Html  ${HTML_FILE}  menu
  @{all_list_elements}  Create List  @{ul_list_elements}  @{ol_list_elements}  @{menu_list_elements}
  # Store id and class references
  FOR  ${elem}  IN  @{all_list_elements}
    @{elem_items}  Create List  ${elem.get('id')}
    FOR  ${item}  IN  @{elem_items}
      IF  '${item}' != 'None'
        Append To List  ${list_ids}  ${item}
      END
    END
    @{elem_items}  Create List  ${elem.get('class')}
    FOR  ${item}  IN  @{elem_items}
      IF  ${item} != None
        Append To List  ${list_classes}  @{item}
      END
    END
  END
  ${css_file_contents}  Get File  ${CSS_FILE}
  # Verify defined table styles
  ${table_styles_found}  Get Regexp Matches  ${css_file_contents}  table\.?\\{([^}]+)\\}
  IF  not ${table_styles_found}
    ${table_styles_found}  Run Keyword And Return Status
    ...  Should Contain Any  ${css_file_contents}  @{table_ids}
    IF  not ${table_styles_found}
      ${table_styles_found}  Run Keyword And Return Status
      ...  Should Contain Any  ${css_file_contents}  @{table_classes}
    END
  END
  # Verify defined list styles
  ${list_styles_found}  Get Regexp Matches  ${css_file_contents}  ul\s*?\\{([^}]+)\\}|ol\s*?\\{([^}]+)\\}|menu\s*?\\{([^}]+)\\}
  IF  not ${list_styles_found}
    ${list_styles_found}  Run Keyword And Return Status
    ...  Should Contain Any  ${css_file_contents}  @{list_ids}
    IF  not ${list_styles_found}
      ${list_styles_found}  Run Keyword And Return Status
      ...  Should Contain Any  ${css_file_contents}  @{list_classes}
    END
  END
  Should Be True  ${table_styles_found}
  Should Be True  ${list_styles_found}

E0-T2-4: Specificity is used in styling
  [Documentation]  Verify that specificity is used to make one row or cell in a table
  ...  or one item in a list appear different from others.
  ...  Based on the tasker describtion the following child elements of tables
  ...  will be considered: <tr>, <td>, <th>.
  ...  These elements can only be compared to other similar elements.
  ...  For lists only <li> elements will be considered.
  ...  Tests will flunk solutions that have used specificity to more than
  ...  exactly one considered child element in any given parent.
  [Tags]  ex0  e0t2  full

  # Create dictionaries to store data for final verification.
  &{table_dict}  Create Dictionary
  &{list_dict}  Create Dictionary
  # Open the html file in browser.
  New Page  ${HTML_FILE}
  # Find table elements from page.
  ${table_elements}  Get Elements  xpath=//table
  # For each table...
  FOR  ${table}  IN  @{table_elements}
    # ... find child elements.
    ${table_child_elements}  Get Elements  ${table}//*
    # For each child element, check if it is a relevant element.
    # If it is, add the element into a corresponding
    # dict as element : style.
    @{tr_list}  Create List
    @{td_list}  Create List
    @{th_list}  Create List
    FOR  ${child}  IN  @{table_child_elements}
      ${item_name}  Get Property  ${child}    tagName
      IF  '${item_name}' == 'TR'
        ${child_element_style}  Get Style  ${child}
        Append To List  ${tr_list}  ${child_element_style}
      ELSE IF  '${item_name}' == 'TD'
        ${child_element_style}  Get Style  ${child}
        Append To List  ${td_list}  ${child_element_style}
      ELSE IF  '${item_name}' == 'TH'
        ${child_element_style}  Get Style  ${child}
        Append To List  ${th_list}  ${child_element_style}
      END
    END
    Set To Dictionary  ${table_dict}  tr  ${tr_list}  td  ${td_list}  th  ${th_list}
  END
  # Verify that at least one row or data cell differs in style from its peers.
  # Interpreting the tasker strictly, the following scenarios are possible:
  # <tr> - 1) all tr are the same; 2) n-1 tr are the same and 1 tr unique
  # <td> / <th> - 1) n-1 are the same and 1 is unique; 2) all the td / th are the same.
  # Regarding elements, the scenarios must correspond. If tr is case 1, td/th must also be case 1.
  # If a looser interpretation is allowed we may assume that the tasker simply asks
  # the student apply specificity. In this case - as far as tester's understanding -
  # each individual cell of an individual row could be unique in styling.
  # We will apply the loose interpretation here and assume that
  # we could i.e. find only unique stylings and still deduce that specificity
  # is used as required since the elements are all from the same parent.
  ${table_specificity}  Verify Specificity Use Based On Styles Count  ${table_dict}  tr
  IF  not ${table_specificity}
    ${table_specificity}  Verify Specificity Use Based On Styles Count  ${table_dict}  td
  END
  # Check cells if specificity not found from rows.
  IF  not ${table_specificity}
    ${table_specificity}  Verify Specificity Use Based On Styles Count  ${table_dict}  th
  END
  # Next check the use of specificity in lists.
  # With lists we will assume the tasker truly means <li> element when
  # it mentions 'one item' in list should be styled by using specificity.
  # This means the test will flunk solutions that have styled the content
  # itself within the <li> element instead of styling the element.
  ${ol_elements}  Get Elements  xpath=//ol[not(parent::li)]
  ${ul_elements}  Get Elements  xpath=//ul[not(parent::li)]
  ${menu_elements}  Get Elements  xpath=//menu[not(parent::li)]
  ${child_element_styles}  Get All Styles From Children Of Type  ${ol_elements}  li
  @{ol_list}  Create List  @{child_element_styles}
  ${child_element_styles}  Get All Styles From Children Of Type  ${ul_elements}  li
  @{ul_list}  Create List  @{child_element_styles}
  ${child_element_styles}  Get All Styles From Children Of Type  ${menu_elements}  li
  @{menu_list}  Create List  @{child_element_styles}
  Set To Dictionary  ${list_dict}  ol  ${ol_list}  ul  ${ul_list}  menu  ${menu_list}
  ${list_specificity}  Verify Specificity Use Based On Styles Count  ${list_dict}  ol
  IF  not ${list_specificity}
    ${list_specificity}  Verify Specificity Use Based On Styles Count  ${list_dict}  ul
  END
  IF  not ${list_specificity}
    ${list_specificity}  Verify Specificity Use Based On Styles Count  ${list_dict}  menu
  END
  Close Page
  Should Be True  ${table_specificity}
  Should Be True  ${list_specificity}

E0-T2-5: Id and class selector are used
  [Documentation]  Ids and class selectors are used to define styles.
  [Tags]  ex0  e0t2  full

  ${html_contents}  Get File  ${HTML_FILE}
  ${html_ids}  Get Regexp Matches  ${html_contents}  .*?id\s*?=\s*?["|'](.*?)["|']  1
  ${html_classes}  Get Regexp Matches  ${html_contents}  .*?class\s*?=\s*?["|'](.*?)["|']  1
  ${css_contents}  Get File  ${CSS_FILE}
  ${css_ids}  Get Regexp Matches  ${css_contents}  .*?#(.*?)\s*?\\{  1
  ${css_classes}  Get Regexp Matches  ${css_contents}  .*?\.(.*?)[^a-z].*?\s*?\\{  1
  ${css_ids}  Sanitize Empty Spaces From Strings  ${css_ids}
  ${css_classes}  Sanitize Empty Spaces From Strings  ${css_classes}
  Should Contain Any  ${html_ids}  @{css_ids}
  Should Contain Any  ${html_classes}  @{css_classes}

E0-T2-6: Element position and sizing options are used
  [Documentation]  Ids and class selectors are used to define styles.
  [Tags]  ex0  e0t2  full  uusi
  
  # FIX FETCHING OF TESTABLE MATERIAL (HTML AND CSS FILES)
  # TO BE PART OF THE SUITE SETUP!
  # THEN REMOVE THE COMMENT-SURROUNDED PART BELOW
  ################################################
  ${css_file}  Search File With Extension  ${TEST_SUBJECT_DIR}  css
  Set Global Variable  ${CSS_FILE}  ${css_file}
  ################################################
  @{position_support_words}  Create List  margin  padding  position  align  top  right  left  bottom
  @{size_support_words}  Create List  height  width  size
  ${css_contents}  Get File  ${CSS_FILE}
  ${found_styles}  Get Regexp Matches  ${css_contents}  margin\s*?:|margin-[a-zA-Z].*:|padding\s*?:|padding-[a-zA-Z].*?:|position\s*?:|[a-zA-Z].*?-align\s*?:|width:|.*?height:|size:
  ${styles_string}  Set Variable
  FOR  ${item}  IN  @{found_styles}
    ${new_item}  Remove String  ${item}  ${SPACE}
    ${styles_string}  Catenate  ${styles_string}  ${new_item}
  END
  Should Contain Any  ${styles_string}  @{position_support_words}
  Should Contain Any  ${styles_string}  @{size_support_words}

*** Keywords ***
Sanitize Empty Spaces From Strings
  [Arguments]  ${strings}
  @{new_list}  Create List
  FOR  ${string}  IN  @{strings}
    ${stripped}  Strip String  ${string}
    Append To List  ${new_list}  ${stripped}
  END
  [Return]  ${new_list}

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

Verify Specificity Use Based On Styles Count
  [Arguments]  ${dict}  ${element}
  ${dict_list}  Get From Dictionary  ${dict}  ${element}
  ${dict_list_count}  Get Length  ${dict_list}
  IF  ${dict_list_count} > 1
    FOR  ${item}  IN  @{dict_list}
      ${style_matches_in_list}  Set Variable  ${dict_list}.count(${item})
      ${specificity}  Evaluate
      ...  ${style_matches_in_list} == 1
      IF  ${specificity}  BREAK
    END
  ELSE
    ${specificity}  Set Variable  ${FALSE}
  END
  [Return]  ${specificity}

Get All Styles From Children Of Type
  [Arguments]  ${source_elements}  ${elem_type}
  ${elem_lower}  Convert To Lower Case  ${elem_type}
  @{child_styles}  Create List
  FOR  ${elem}  IN  @{source_elements}
    ${all_list_items}  Get Elements  ${elem}//${elem_lower}
    FOR  ${item}  IN  @{all_list_items}
      ${style}  Get Style  ${item}
      Append To List  ${child_styles}  ${style}
    END
  END
  ${tut}  Get Length  ${child_styles}
  [Return]  ${child_styles}