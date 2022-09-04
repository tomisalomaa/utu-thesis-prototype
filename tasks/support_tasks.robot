*** Settings ***
Library  OperatingSystem
Library  String
Library  Collections
Library  ..${/}libraries${/}MyLibrary.py
Variables  ..${/}variables${/}common_variables.py
Resource  ..${/}resources${/}common_keywords.resource

*** Tasks ***
Find e1t1 File For Dynamic Testing
  [Tags]  e1t1
  @{course_js_keywords}  Create List  exercise  course  part
  ${course_js_file}  Find Most Recent File Based On Keywords  ${SUT_DIR}${/}  ${course_js_keywords}  js
  Set Global Variable  ${COURSE_JS_FILE}  ${course_js_file}

Move Index Files To Dynamic Test SRC Directory
  [Tags]  e1t1
  Copy File  ${COURSE_JS_FILE}  ${DYNA_DIR}src/

Find e1t2 File For Dynamic Testing
  [Tags]  e1t2
  @{feedback_js_keywords}  Create List  statistic  neutr  posi
  ${feedback_js_file}  Find Most Recent File Based On Keywords  ${SUT_DIR}${/}  ${feedback_js_keywords}  js
  Set Global Variable  ${FEEDBACK_JS_FILE}  ${feedback_js_file}

Move e1t2 Index Files To Dynamic Test SRC Directory
  [Tags]  e1t2
  Copy File  ${FEEDBACK_JS_FILE}  ${DYNA_DIR}src/

Find e2t1 Directory For Dynamic Testing
  [Tags]  e2t1
  @{course_js_keywords}  Create List  App  course  parts
  ${course_js_file}  Find Most Recent File Based On Keywords  ${SUT_DIR}${/}  ${course_js_keywords}  js
  ${course_root_dir}  Split String From Right  ${course_js_file}  src
  Copy Directory Contents  ${course_root_dir}[0]  ${DYNA_DIR}

Find e2t2 Directory For Dynamic Testing
  [Tags]  e2t2
  @{phonebook_js_keywords}  Create List  App  phone
  ${phonebook_js_file}  Find Most Recent File Based On Keywords  ${SUT_DIR}${/}  ${phonebook_js_keywords}  js
  ${phonebook_root_dir}  Split String From Right  ${phonebook_js_file}  src
  Copy Directory Contents  ${phonebook_root_dir}[0]  ${DYNA_DIR}
  Copy File  ${RES_DIR}${/}db.json  ${DYNA_DIR}db.json