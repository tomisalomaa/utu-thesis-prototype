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
E2-T1-1: Content Is Structured Correctly
  [Documentation]  Course component takes care of structuring the contents of a single Course.
  ...  The component itself should contain course name and its parts with part details.
  ...  The component is then used to render the course information.
  [Tags]  ex2  e2t1  full
  ${app_content_pass}  Run Keyword And Return Status
  ...  Test Content Structuring From Content  ${COURSE_APP_FILE_CONTENTS}
  Pass Execution If  ${app_content_pass}  Structure OK
  Test Content Structuring From Content  ${COURSE_INDEX_FILE_CONTENTS}

E2-T1-3: Module Separation Is Implemented
  [Documentation]  App component imports Course module.
  [Tags]  ex2  e2t1  full
  IF  ${COURSE_APP_EXISTS}
    ${file_contents}  Set Variable  ${COURSE_APP_FILE_CONTENTS}
    ${app_dir_lower}  Convert To Lower Case  ${COURSE_APP_FILE}
    ${src_location}  Split String From Right  ${app_dir_lower}  app.js
  ELSE
    ${file_contents}  Set Variable  ${COURSE_INDEX_FILE_CONTENTS}
    ${app_dir_lower}  Convert To Lower Case  ${COURSE_INDEX_FILE}
    ${src_location}  Split String From Right  ${app_dir_lower}  index.js
  END
  ${app_imports}  Get Regexp Matches  ${file_contents}  import.*?from\\s*?['|"].*?['|"]
  FOR  ${import}  IN  @{app_imports}
    ${course_import_found}  Get Regexp Matches  ${file_contents}  ['|"]\\.(.*?[cC]ourse).*?['|"]  1
    IF  ${course_import_found}
      ${course_import_dir}  Set Variable  ${course_import_found}[0]
    END
  END
  ${src_location}  Set Variable  ${src_location}[0]
  ${course_import_dir}  Catenate  SEPARATOR=  ${src_location}  ${course_import_dir}  .js
  Should Exist  ${course_import_dir}

E2-T2-2: App Is Divided Into Several Components
  [Documentation]  App is divided into several components.
  ...  The state should remain in the root component.
  [Tags]  ex2  e2t2  full
  ${app_imports}  Get Regexp Matches  ${PHONEBOOK_APP_FILE_CONTENTS}  import.*?from\\s*?['|"].*?['|"]
  ${number_of_imports}  Get Length  ${app_imports}
  Should Be True  ${number_of_imports} >= 2
  ${course_import_found}  Get Regexp Matches  ${PHONEBOOK_APP_FILE_CONTENTS}  ['|"]\\.\\/(.*?)['|"]  1
  ${app_dir_lower}  Convert To Lower Case  ${PHONEBOOK_APP_FILE}
  ${src_location}  Split String From Right  ${app_dir_lower}  app.js
  ${src_location}  Set Variable  ${src_location}[0]
  FOR  ${import}  IN  @{course_import_found}
    ${import_dir}  Catenate  SEPARATOR=  ${src_location}  ${import}  .js
    Should Exist  ${import_dir}
  END

E2-T2-4: Initial App State Is Stored Into File
  [Documentation]  Initial state of the app is in the file db.json in the root directory of the project.
  [Tags]  ex2  e2t2  full
  ${root_dir}  Split String From Right  ${PHONEBOOK_APP_FILE}  src
  ${root_dir}  Set Variable  ${root_dir}[0]
  @{json_files}  List Files In Directory  ${root_dir}  *.json  absolute
  FOR  ${file}  IN  @{json_files}
    ${file_name}  Split String From Right  ${file}  ${/}  1
    ${file_name}  Set Variable  ${file_name}[1]
    IF  '${file_name}' != 'package-lock.json' and '${file_name}' != 'package.json'
      ${db_file}  Set Variable  ${file}
    END
  END
  ${db_file_contents}  Get File  ${db_file}
  Should Match Regexp  ${db_file_contents}  person
  Should Match Regexp  ${db_file_contents}  \\[.*?[\\s\\S]*?\\]
  Should Match Regexp  ${db_file_contents}  {.*?[\\s\\S]*?}
  Should Match Regexp  ${db_file_contents}  name
  Should Match Regexp  ${db_file_contents}  number
  Should Match Regexp  ${db_file_contents}  id

*** Keywords ***
Initiate Static Testing
  @{course_js_keywords}  Create List  export  default  App  course
  @{phonebook_js_keywords}  Create List  export  default  App  person
  ${course_app_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  app  js
  ${app_found}  Run Keyword And Return Status
  ...  File Should Exist  ${course_app_file}
  Set Global Variable  ${COURSE_APP_EXISTS}  ${app_found}
  ${app_dir_lower}  Convert To Lower Case  ${course_app_file}
  ${src_location}  Split String From Right  ${app_dir_lower}  app.js
  ${src_location}  Set Variable  ${src_location}[0]
  ${course_index_file}  Catenate  SEPARATOR=  ${src_location}  index.js
  ${index_found}  Run Keyword And Return Status
  ...  File Should Exist  ${course_index_file}
  IF  not ${index_found}
    @{course_js_keywords}  Create List  ReactDOM  import  React  App  course
    ${course_index_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  index  js
  END
  File Should Exist  ${course_index_file}
  Set Global Variable  ${COURSE_INDEX_FILE}  ${course_index_file}
  ${phonebook_app_file}  Find Most Recent File Based On Keywords And Name  ${TEST_SUBJECT_DIR}${/}  ${phonebook_js_keywords}  app  js
  IF  ${app_found}
    Set Global Variable  ${COURSE_APP_FILE}  ${course_app_file}
    ${course_app_file_contents}  Get File  ${COURSE_APP_FILE}
    Set Global Variable  ${COURSE_APP_FILE_CONTENTS}  ${course_app_file_contents}
  END
  Set Global Variable  ${COURSE_INDEX_FILE}  ${course_index_file}
  ${course_index_file_contents}  Get File  ${COURSE_INDEX_FILE}
  Set Global Variable  ${COURSE_INDEX_FILE_CONTENTS}  ${course_index_file_contents}
  Set Global Variable  ${PHONEBOOK_APP_FILE}  ${phonebook_app_file}
  ${phonebook_app_file_contents}  Get File  ${PHONEBOOK_APP_FILE}
  Set Global Variable  ${PHONEBOOK_APP_FILE_CONTENTS}  ${phonebook_app_file_contents}  

Test Content Structuring From Content
  [Arguments]  ${base_contents}
  #${course_data}  Get Regexp Matches  ${base_contents}  (const\\s*?[cC]ourse\\s*?=\\s*?{[\\s\\S]*?}[\\s\\S]*?)retur  1
  ${name_data}  Get Regexp Matches  ${base_contents}  (name\\s*?:[\\s\\S]*?['|"].*?['|"])  1
  ${name_data}  Get Length  ${name_data}
  ${name_data_entries}  Evaluate  ${name_data} > 0
  Should Be True  ${name_data_entries}
  ${parts_data}  Get Regexp Matches  ${base_contents}  (parts\\s*?:[\\s\\S]*?\\[[\\s\\S]*?\\])  1
  ${part_names}  Get Regexp Matches  ${parts_data}[0]  name
  ${part_exercises}  Get Regexp Matches  ${parts_data}[0]  exercises
  ${part_ids}  Get Regexp Matches  ${parts_data}[0]  id
  ${exercise_reg_hits}  Get Length  ${part_exercises}
  Length Should Be  ${part_names}  ${exercise_reg_hits}
  ${id_reg_hits}  Get Length  ${part_ids}
  Length Should Be  ${part_exercises}  ${id_reg_hits}