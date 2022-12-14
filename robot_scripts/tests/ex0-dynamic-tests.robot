*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         RequestsLibrary
Library         ExcelLibrary
Library         ${LIBRARIES_DIR}${/}MyLibrary.py
Variables       ${GLOBAL_ROBO_VARIABLES_DIR}${/}common_variables.py
Resource        ${RESOURCES_DIR}${/}common_keywords.resource
Suite Setup     Initiate Dynamic Testing

*** Test Cases ***
E0-T1-5-1: Page contains an image element
  [Documentation]  Page has at least one img element
  [Tags]  ex0  e0t1
  &{verified_img_results}  Create Dictionary  pass=${0}  fail=${0}
  New Page  file://${HTML_FILE}
  ${img_elements}  Get Elements  xpath=//img
  Should Not Be Empty  ${img_elements}

E0-T1-5-2: Page contains a valid image element
  [Documentation]  Page has at least one img element with content included.
  ...  Element is verifiably correct if it contains the src attribute
  ...  with a non-broken value.
  ...  This test case does not require verifying from a raw file:
  ...  1) There is no need to check for hierarchies or element relations.
  ...  2) If the test object is missing src property or its contents,
  ...     it will be caught all the same as a broken image even when
  ...     html parsers are used.
  [Tags]  ex0  e0t1
  &{verified_img_results}  Create Dictionary  pass=${0}  fail=${0}
  New Page  file://${HTML_FILE}
  ${img_elements}  Get Elements  xpath=//img
  FOR  ${img}  IN  @{img_elements}
    ${src_attr}  Get Attribute  ${img}  src
    ${src_try_local}  Append Path To File Found From Index Html  ${src_attr}
    ${img_is_local}  Run Keyword And Return Status
    ...  File Should Exist  ${src_try_local}
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
  Take Screenshot
  Close Page
  Should Be True  ${verified_img_results['pass']} > 0

E0-T1-6: Page contains a form with input elements
  [Documentation]  Page has at least one form element containing input elements.
  ...  Action attribute need not be defined.
  [Tags]  ex0  e0t1
  &{verified_form_inputs}  Create Dictionary  pass=${0}  fail=${0}
  @{allowed_input_types}  Create List
  ...  button  checkbox  color  date  datetime-local
  ...  email  file  hidden  image  month
  ...  number  password  radio  range  reset
  ...  search  submit  tel  text  time
  ...  url  week
  New Page  file://${HTML_FILE}
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
  Take Screenshot
  Close Page
  Should Be True  ${verified_form_inputs['pass']} > 0

E0-T2-4: Specificity is used in styling
  [Documentation]  Verify that specificity is used to make one row or cell in a table
  ...  or one item in a list appear different from others.
  ...  Based on the tasker describtion the following child elements of tables
  ...  will be considered: <tr>, <td>, <th>.
  ...  These elements can only be compared to other similar elements.
  ...  For lists only <li> elements will be considered.
  ...  Tests will flunk solutions that have used specificity to more than
  ...  exactly one considered child element in any given parent.
  [Tags]  ex0  e0t2
  &{table_dict}  Create Dictionary
  &{list_dict}  Create Dictionary
  New Page  file://${HTML_FILE}
  ${table_elements}  Get Elements  xpath=//table
  FOR  ${table}  IN  @{table_elements}
    ${table_child_elements}  Get Elements  ${table}//*
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
  ${table_specificity}  Verify Specificity Use Based On Styles Count  ${table_dict}  tr
  IF  not ${table_specificity}
    ${table_specificity}  Verify Specificity Use Based On Styles Count  ${table_dict}  td
  END
  IF  not ${table_specificity}
    ${table_specificity}  Verify Specificity Use Based On Styles Count  ${table_dict}  th
  END
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
  Take Screenshot
  Close Page
  ${specificity_used}  Evaluate  ${table_specificity} or ${list_specificity}
  Should Be True  ${specificity_used}

*** Keywords ***
Initiate Dynamic Testing
  Log  ${TEST_SUBJECT_DIR}
  ${html_file}  Search Local HTML Main Page Location  ${TEST_SUBJECT_DIR}
  Should Not Be Empty  ${html_file}
  Set Global Variable  ${HTML_FILE}  ${html_file}

Append Path To File Found From Index Html
  [Arguments]  ${src}
  ${index_file_loc}  ${index_file}  Split String From Right  ${HTML_FILE}  ${/}  max_split=1
  ${src}  Set Variable  ${index_file_loc}${/}${src}
  [Return]  ${src}

Get Status Of Web Source
  [Arguments]  ${src}
  ${url_protocol}  Get Regexp Matches  ${src}  http:\\/\\/|https:\\/\\/
  ${src}  Set Variable If  ${url_protocol}  ${src}  https:\/\/${src}
  ${response}  GET  ${src}
  [Return]  ${response.ok}

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
  [Return]  ${child_styles}