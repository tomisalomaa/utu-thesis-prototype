*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         ${LIBRARIES_DIR}${/}MyLibrary.py
Variables       ${GLOBAL_ROBO_VARIABLES_DIR}${/}common_variables.py
Resource        ${RESOURCES_DIR}${/}common_keywords.resource
Suite Setup     Initiate Static Testing

*** Test Cases ***
E1-T1-1: Course App Consists Of Three Main Components
  [Documentation]  Source code has the three main components: Header, Contents and Total. 
  [Tags]  ex1  e1t1  full
  Should Match Regexp  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[hH]eader.*?\\/\\s*?>
  Should Match Regexp  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[cC]ontents.*?\\/\\s*?>
  Should Match Regexp  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[tT]otal.*?\\/\\s*?>

E1-T1-2: Course App Contents Consist Of Part Components
  [Documentation]  Contents should contain three Part components.
  [Tags]  ex1  e1t1  full
  ${component_regexp}  Set Variable  const\\s*?[cC]ontents\\s*?=\\s*?\\(\\s*?props\\s*?\\).*?=>[\\s\\S]*?{[\\s\\S]*?\\)[\\s\\S]*?}
  ${part_component_regexp}  Set Variable  <\\s*?[pP]art.*?[\\s\\S]*?\\/[\\s]*?>
  ${contents_component}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  ${component_regexp}
  ${part_components}  Get Regexp Matches  ${contents_component}[0]  ${part_component_regexp}
  Length Should Be  ${part_components}  3

E1-T1-3: Course App Data In Objects
  [Documentation]  Expected objects are declared and they contain the expected data.
  ...  Expected objects are 'course' and 'parts';
  ...  'course' should contain 'name' and
  ...  'parts' an array of key-value pairs consisting of 'name' and 'exercises'.
  [Tags]  ex1  e1t1  full
  ${course_object_regexp}  Set Variable  (const\\s*?[cC]ourse\\s*?=\\s*?{[\\s\\S]*?}[\\s\\S]*?)retur
  ${name_data_regexp}  Set Variable  (name\\s*?:[\\s\\S]*?['|"].*?['|"])
  ${parts_data_regexp}  Set Variable  (parts\\s*?:[\\s\\S]*?\\[[\\s\\S]*?\\])
  ${parts_data_keyvalues_regexp}  Set Variable  {([\\s\\S]*?.*?\\s*?:.*?,[\\s\\S]*?.*?:.*?[\\s\\S]*?)}
  ${course_object}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  ${course_object_regexp}  1
  ${name_data}  Get Regexp Matches  ${course_object}[0]  ${name_data_regexp}  1
  Length Should Be  ${name_data}  4
  ${parts_data}  Get Regexp Matches  ${course_object}[0]  ${parts_data_regexp}  1
  ${parts_data_keyvalues}  Get Regexp Matches  ${parts_data}[0]  ${parts_data_keyvalues_regexp}  1
  Length Should Be  ${parts_data_keyvalues}  3
  FOR  ${part}  IN  @{parts_data_keyvalues}
    Should Match Regexp  ${part}  [nN]ame
    Should Match Regexp  ${part}  [eE]xercise
  END

E1-T1-4: Course App Props Are Passed Directly
  [Documentation]  Objects should not be passed between components but rather as an array directly.
  [Tags]  ex1  e1t1  full
  ${header}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[hH]eader.*?\\/\\s*?>
  ${contents}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[cC]ontents.*?\\/\\s*?>
  ${total}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[tT]otal.*?\\/\\s*?>
  Should Match Regexp  ${header}[0]  .*?(=\\s*?{\\s*?course\\s*?})
  Should Match Regexp  ${contents}[0]  .*?(=\\s*?{\\s*?course\\s*?})
  Should Match Regexp  ${total}[0]  .*?(=\\s*?{\\s*?course\\s*?})

E1-T2-3: Feedback App Contains Several Components
  [Documentation]  App contains the following components: 1) Button, 2) Statistics and 3) Statistic.
  [Tags]  ex1  e1t2  full
  Should Match Regexp  ${FEEDBACK_JS_FILE_CONTENTS}  const\\s*?[bB]utton\\s*?=\\s*?\\(\\s*?.*?\\s*?\\).*?=>
  Should Match Regexp  ${FEEDBACK_JS_FILE_CONTENTS}  const\\s*?[sS]tatistics\\s*?=\\s*?\\(\\s*?.*?\\s*?\\).*?=>
  Should Match Regexp  ${FEEDBACK_JS_FILE_CONTENTS}  const\\s*?[sS]tatistic\\s*?=\\s*?\\(\\s*?.*?\\s*?\\).*?=>

*** Keywords ***
Initiate Static Testing
  @{course_js_keywords}  Create List  exercise  course  part
  @{feedback_js_keywords}  Create List  statistic  neutr  posi
  ${course_js_file}  Find Most Recent File Based On Keywords  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  js
  ${feedback_js_file}  Find Most Recent File Based On Keywords  ${TEST_SUBJECT_DIR}${/}  ${feedback_js_keywords}  js
  Set Global Variable  ${COURSE_JS_FILE}  ${course_js_file}
  Set Global Variable  ${FEEDBACK_JS_FILE}  ${feedback_js_file}
  ${course_js_file_contents}  Get File  ${COURSE_JS_FILE}
  ${feedback_js_file_contents}  Get File  ${FEEDBACK_JS_FILE}
  Set Global Variable  ${COURSE_JS_FILE_CONTENTS}  ${course_js_file_contents}
  Set Global Variable  ${FEEDBACK_JS_FILE_CONTENTS}  ${feedback_js_file_contents}