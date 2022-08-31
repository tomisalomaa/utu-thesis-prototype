*** Settings ***
Library  OperatingSystem
Library  String
Library  Collections
Variables  ..${/}variables${/}common_variables.py
Resource  ..${/}resources${/}common_keywords.resource

*** Tasks ***
Find e1t1 File For Dynamic Testing
  [Tags]  e1t1
  @{course_js_keywords}  Create List  exercise  course  part
  ${course_js_file}  Find Most Recent File Based On Keywords  ${SUT_FOLDER}${/}  ${course_js_keywords}  js
  Set Global Variable  ${COURSE_JS_FILE}  ${course_js_file}

Move e1t1 Index Files To Dynamic Test SRC Folder
  [Tags]  e1t1
  Copy File  ${COURSE_JS_FILE}  ${DYNA_FOLDER}src/

Find e1t2 File For Dynamic Testing
  [Tags]  e1t2
  @{feedback_js_keywords}  Create List  statistic  neutr  posi
  ${feedback_js_file}  Find Most Recent File Based On Keywords  ${SUT_FOLDER}${/}  ${feedback_js_keywords}  js
  Set Global Variable  ${FEEDBACK_JS_FILE}  ${feedback_js_file}

Move e1t2 Index Files To Dynamic Test SRC Folder
  [Tags]  e1t2
  Copy File  ${FEEDBACK_JS_FILE}  ${DYNA_FOLDER}src/