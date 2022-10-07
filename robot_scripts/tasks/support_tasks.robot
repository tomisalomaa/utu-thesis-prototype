*** Settings ***
Library     OperatingSystem
Library     String
Library     Collections
Library     ${LIBRARIES_DIR}${/}MyLibrary.py
Variables   ${GLOBAL_ROBO_VARIABLES_DIR}${/}common_variables.py
Resource    ${RESOURCES_DIR}${/}common_keywords.resource

*** Tasks ***
Find And Copy e1t1 File For Dynamic Testing
  [Tags]  e1t1
  @{course_js_keywords}  Create List  exercise  course  part
  ${course_js_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  index  js
  Set Global Variable  ${COURSE_JS_FILE}  ${course_js_file}
  Copy File  ${COURSE_JS_FILE}  ${DYNA_DIR}src/
  Move Test Automation Support Files To Test Directory  ex1
  
Find And Copy e1t2 File For Dynamic Testing
  [Tags]  e1t2
  @{feedback_js_keywords}  Create List  statistic  neutr  posi
  ${feedback_js_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${feedback_js_keywords}  index  js
  Set Global Variable  ${FEEDBACK_JS_FILE}  ${feedback_js_file}
  Copy File  ${FEEDBACK_JS_FILE}  ${DYNA_DIR}src/
  Move Test Automation Support Files To Test Directory  ex1

Find And Copy e2t1 Directory For Dynamic Testing
  [Tags]  e2t1
  @{course_js_keywords}  Create List  export  default  App  course
  ${course_js_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  app  js
  ${app_found}  Run Keyword And Return Status
  ...  File Should Exist  ${course_js_file}
  IF  not ${app_found}
    @{course_js_keywords}  Create List  ReactDOM  import  React  App  course
    ${course_js_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  index  js
  END
  File Should Exist  ${course_js_file}
  ${course_root_dir}  Split String From Right  ${course_js_file}  src
  Copy Directory Contents  ${course_root_dir}[0]  ${DYNA_DIR}
  # we can use the same package files as with ex1
  Move Test Automation Support Files To Test Directory  ex1

Find And Copy e2t2 Directory For Dynamic Testing
  [Tags]  e2t2
  @{phonebook_js_keywords}  Create List  export  default  App  person
  ${phonebook_js_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${phonebook_js_keywords}  app  js
  ${phonebook_root_dir}  Split String From Right  ${phonebook_js_file}  src
  Copy Directory Contents  ${phonebook_root_dir}[0]  ${DYNA_DIR}
  Copy File  ${RESOURCES_DIR}${/}db.json  ${DYNA_DIR}db.json
  # we can use the same package files as with ex1
  Move Test Automation Support Files To Test Directory  ex1

Find And Copy e3t1 Directory For Dynamic Testing
  [Tags]  e3t1
  @{package_json_files}  Create List
  ${files}  Search File With Extension  ${TEST_SUBJECT_DIR}${/}  json
  FOR  ${file}  IN  @{files}
    ${file_name}  Fetch From Right  ${file}  ${/}
    IF  '${file_name}' == 'package.json'
      ${current_located_dir}  Split String From Right  ${file}  ${file_name}
      ${expected_index_file}  Catenate  SEPARATOR=  ${current_located_dir}[0]  index.js
      ${index_is_in_same_dir}  Run Keyword And Return Status
      ...  File Should Exist  ${expected_index_file}
      IF  ${index_is_in_same_dir}
        Append To List  ${package_json_files}  ${file}
      END
    END
  END
  ${package_json}  Determine Most Recently Modified  ${package_json_files}
  ${submitted_project_dir}  Split String From Right  ${package_json}  package.json
  Copy Directory Contents  ${submitted_project_dir}[0]  ${DYNA_DIR}
  Move Test Automation Support Files To Test Directory  ex3

Rename Module Imports From Index And Verify Port
  [Tags]  e3t1
  File Should Exist  ${DYNA_DIR}${/}index.js
  ${index_contents}  Get File  ${DYNA_DIR}${/}index.js
  ${index_contents}  Replace String Using Regexp  ${index_contents}  require\\(['|"](.*?models\\/Person['|"])\\)  require('./models/person')
  ${port_variable}  Get Regexp Matches  ${index_contents}  app.listen\\(\\s*?(.*?),  1
  ${port_variable}  Set Variable  ${port_variable}[0]
  ${index_contents}  Replace String Using Regexp  ${index_contents}  ${port_variable}\\s*?=\\s*?[0-9].*?\\s  ${port_variable} = 3001${\n}  count=1
  Create File  ${DYNA_DIR}${/}index.js  ${index_contents}

Check And Rename Module Files
  [Tags]  e3t1
  # Assumes certain directory structure, namely that 'models' dir exists.
  # In some cases this test may still fail but it doesn't necessarily mean
  # the submission won't work.
  # In other cases it might result into the actual test cases producing false negatives.
  Directory Should Exist  ${DYNA_DIR}${/}models
  @{files}  List Files In Directory  ${DYNA_DIR}${/}models  *.js  absolute
  Skip If  not ${files}
  FOR  ${file}  IN  @{files}
    ${directory}  ${filename}  Split String From Right  ${file}  ${/}  1
    ${filename}  Convert To Lower Case  ${filename}
    ${directory}  Catenate  SEPARATOR=  ${directory}  ${/}${filename}
    Move File  ${file}  ${directory}
  END

Fix Mongodb Connection Strings
  [Tags]  e3t1
  ${new_mongo_url}  Set Variable  'mongodb://admin:admin@127.0.0.1:27017/ex3tests?authSource=admin'
  Search And Replace Mongo Connection Strings  ${new_mongo_url}

Fix API Paths
  [Tags]  e3t1
  # the fact that this needs to be done means
  # a) the student has failed to abide the api requirements (path would be considered quite strict and important in work life) and
  # b) the way api has been implemented probably requires static tests to verify.
  # Should affect total score even if functionality is there?
  File Should Exist  ${DYNA_DIR}${/}index.js
  ${index_contents}  Get File  ${DYNA_DIR}${/}index.js
  Log  ${index_contents}
  ${api_paths}  Get Regexp Matches  ${index_contents}  \\.get\\(['|"](.*?\\/persons?).*?['|"]|\\.post\\(['|"](.*?\\/persons?).*?['|"]|\\.delete\\(['|"](.*?\\/persons?).*?['|"]  1
  ${api_paths}  Remove Duplicates  ${api_paths}
  FOR  ${path}  IN  @{api_paths}
    IF  '${path}' != 'None'
      ${path}  Replace String  ${path}  /  \\/
      ${index_contents}  Replace String Using Regexp  ${index_contents}  ${path}  /api/persons
    END
  END
  Log  ${index_contents}
  Create File  ${DYNA_DIR}${/}index.js  ${index_contents} 

*** Keywords ***
Search And Replace Mongo Connection Strings
  [Arguments]  ${new_mongo_string}
  @{directories_to_search}  List Directories In Directory  ${DYNA_DIR}  *  absolute
  Append To List  ${directories_to_search}  ${DYNA_DIR}
  ${non_directories}  Get Matches  ${directories_to_search}  .*
  Remove Values From List  ${directories_to_search}  @{non_directories}
  FOR  ${directory_to_search}  IN  @{directories_to_search}
    @{files}  List Files In Directory  ${directory_to_search}  *.js  absolute
    FOR  ${file}  IN  @{files}
      ${file_contents}  Get File  ${file}
      ${file_contents}  Replace String Using Regexp  ${file_contents}  ["|']mongod.*?["|']|process\\.env\\.[mM][a-zA-Z]*[_]?[a-zA-Z]*\\S|process\\.env\\.[uU][a-zA-Z]*[_]?[a-zA-Z]*\\S  ${new_mongo_string}
      Create File  ${file}  ${file_contents}
    END
  END

Move Test Automation Support Files To Test Directory
  [Arguments]  ${ex}
  Copy File  ${RESOURCES_DIR}${/}package-${ex}.json  ${DYNA_DIR}package.json
  Copy File  ${RESOURCES_DIR}${/}package-lock-${ex}.json  ${DYNA_DIR}package-lock.json