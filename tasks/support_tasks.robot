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

Copy e1t2 Index Files To Dynamic Test SRC Directory
  [Tags]  e1t2
  Copy File  ${FEEDBACK_JS_FILE}  ${DYNA_DIR}src/

Find And Copy e2t1 Directory For Dynamic Testing
  [Tags]  e2t1
  @{course_js_keywords}  Create List  App  course  parts
  ${course_js_file}  Find Most Recent File Based On Keywords  ${SUT_DIR}${/}  ${course_js_keywords}  js
  ${course_root_dir}  Split String From Right  ${course_js_file}  src
  Copy Directory Contents  ${course_root_dir}[0]  ${DYNA_DIR}

Find And Copy e2t2 Directory For Dynamic Testing
  [Tags]  e2t2
  @{phonebook_js_keywords}  Create List  App  phone
  ${phonebook_js_file}  Find Most Recent File Based On Keywords  ${SUT_DIR}${/}  ${phonebook_js_keywords}  js
  ${phonebook_root_dir}  Split String From Right  ${phonebook_js_file}  src
  Copy Directory Contents  ${phonebook_root_dir}[0]  ${DYNA_DIR}
  Copy File  ${RES_DIR}${/}db.json  ${DYNA_DIR}db.json

Find And Copy e3t1 Directory For Dynamic Testing
  [Tags]  e3t1
  @{package_json_files}  Create List
  ${files}  Search File With Extension  ${SUT_DIR}${/}  json
  FOR  ${file}  IN  @{files}
    ${file_name}  Fetch From Right  ${file}  ${/}
    IF  '${file_name}' == 'package.json'
      Append To List  ${package_json_files}  ${file}
    END
  END
  ${package_json}  Determine Most Recently Modified  ${package_json_files}
  ${submitted_project_dir}  Split String From Right  ${package_json}  package.json
  Copy Directory Contents  ${submitted_project_dir}[0]  ${DYNA_DIR}

Check And Rename Module Files
  [Tags]  e3t1
  # this should be tied more to the actual file names,
  # current solution works for student 21 as a demo
  @{files}  List Files In Directory  ${DYNA_DIR}${/}models  *.js  absolute
  Skip If  not ${files}
  FOR  ${file}  IN  @{files}
    ${directory}  ${filename}  Split String From Right  ${file}  ${/}  1
    ${filename}  Convert To Lower Case  ${filename}
    ${directory}  Catenate  SEPARATOR=  ${directory}  ${/}${filename}
    Move File  ${file}  ${directory}
  END

Rename Module Imports From Index
  [Tags]  e3t1
  ${index_contents}  Get File  ${DYNA_DIR}${/}index.js
  ${index_contents}  Replace String Using Regexp  ${index_contents}  require\\(['|"](.*?models\\/Person['|"])\\)  require('./models/person')
  Create File  ${DYNA_DIR}${/}index.js  ${index_contents}

Fix Mongodb Connection Strings
  [Tags]  e3t1
  ${new_mongo_url}  Set Variable  'mongodb://admin:admin@127.0.0.1:27017/ex3tests?authSource=admin'
  Search And Replace Mongo Connection Strings From Folder  ${DYNA_DIR}${/}  ${new_mongo_url}
  Search And Replace Mongo Connection Strings From Folder  ${DYNA_DIR}${/}models  ${new_mongo_url}

Fix API Paths
  [Tags]  e3t1
  # the fact that this needs to be done means
  # a) the student has failed to abide the api requirements (path would be considered quite strict and important in work life) and
  # b) the way api has been implemented probably requires static tests to verify.
  # Should affect total score even if functionality is there?
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
Search And Replace Mongo Connection Strings From Folder
  [Arguments]  ${dir_location}  ${new_mongo_string}
  @{files}  List Files In Directory  ${dir_location}  *.js  absolute
  FOR  ${file}  IN  @{files}
    ${file_contents}  Get File  ${file}
    ${file_contents}  Replace String Using Regexp  ${file_contents}  ["|']mongod.*?["|']  ${new_mongo_string}
     Create File  ${file}  ${file_contents}
  END