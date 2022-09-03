*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         ..${/}libraries${/}MyLibrary.py
Variables       ..${/}variables${/}common_variables.py
Resource        ..${/}resources${/}common_keywords.resource
Suite Setup     Initiate Static Testing

*** Test Cases ***
E2-T1-1: Content Structuring
  [Documentation]  Course component takes care of structuring the contents of a single Course.
  ...  The component itself should contain course name and its parts with part details.
  ...  The component is then used to render the course information.
  [Tags]  ex2  e2t1  full
  Should Match Regexp  ${COURSE_JS_FILE_CONTENTS}  <\\s*?[cC]ourse.*?=\\s*?{.*?}\\s*?\\/\\s*?>
  ${course_data}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  (const\\s*?[cC]ourse\\s*?=\\s*?{[\\s\\S]*?}[\\s\\S]*?)retur  1
  ${name_data}  Get Regexp Matches  ${course_data}[0]  (name\\s*?:[\\s\\S]*?['|"].*?['|"])  1
  Length Should Be  ${name_data}  4
  ${parts_data}  Get Regexp Matches  ${course_data}[0]  (parts\\s*?:[\\s\\S]*?\\[[\\s\\S]*?\\])  1
  ${part_names}  Get Regexp Matches  ${parts_data}[0]  name
  ${part_exercises}  Get Regexp Matches  ${parts_data}[0]  exercises
  ${part_ids}  Get Regexp Matches  ${parts_data}[0]  id
  ${exercise_reg_hits}  Get Length  ${part_exercises}
  Length Should Be  ${part_names}  ${exercise_reg_hits}
  ${id_reg_hits}  Get Length  ${part_ids}
  Length Should Be  ${part_exercises}  ${id_reg_hits}

E2-T1-3: Module Separation
  [Documentation]  App component imports Course module.
  [Tags]  ex2  e2t1  full
  ${app_imports}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  import.*?from\\s*?['|"].*?['|"]
  FOR  ${import}  IN  @{app_imports}
    ${course_import_found}  Get Regexp Matches  ${COURSE_JS_FILE_CONTENTS}  ['|"]\\.(.*?[cC]ourse)['|"]  1
    IF  ${course_import_found}
      ${course_import_dir}  Set Variable  ${course_import_found}[0]
    END
  END
  ${src_location}  Split String From Right  ${COURSE_JS_FILE}  App.js
  ${src_location}  Set Variable  ${src_location}[0]
  ${course_import_dir}  Catenate  SEPARATOR=  ${src_location}  ${course_import_dir}  .js
  Should Exist  ${course_import_dir}

E2-T2-2: App Is Divided Into Several Components
  [Documentation]  App is divided into several components.
  ...  The state should remain in the root component.
  [Tags]  ex2  e2t2  full
  ${app_imports}  Get Regexp Matches  ${PHONEBOOK_JS_FILE_CONTENTS}  import.*?from\\s*?['|"].*?['|"]
  ${number_of_imports}  Get Length  ${app_imports}
  Should Be True  ${number_of_imports} >= 2
  ${course_import_found}  Get Regexp Matches  ${PHONEBOOK_JS_FILE_CONTENTS}  ['|"]\\.\\/(.*?)['|"]  1
  ${src_location}  Split String From Right  ${PHONEBOOK_JS_FILE}  App.js
  ${src_location}  Set Variable  ${src_location}[0]
  FOR  ${import}  IN  @{course_import_found}
    ${import_dir}  Catenate  SEPARATOR=  ${src_location}  ${import}  .js
    Should Exist  ${import_dir}
  END

E2-T2-4: Initial App State Is Stored Into File
  [Documentation]  Initial state of the app is in the file db.json in the root directory of the project.
  [Tags]  ex2  e2t2  full
  ${root_dir}  Split String From Right  ${PHONEBOOK_JS_FILE}  src
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
  @{course_js_keywords}  Create List  App  course  parts
  @{phonebook_js_keywords}  Create List  App  phone  
  ${course_js_file}  Find Most Recent File Based On Keywords  ${TEST_SUBJECT_DIR}${/}  ${course_js_keywords}  js
  ${phonebook_js_file}  Find Most Recent File Based On Keywords  ${TEST_SUBJECT_DIR}${/}  ${phonebook_js_keywords}  js
  Set Global Variable  ${COURSE_JS_FILE}  ${course_js_file}
  Set Global Variable  ${PHONEBOOK_JS_FILE}  ${phonebook_js_file}
  ${course_js_file_contents}  Get File  ${COURSE_JS_FILE}
  ${phonebook_js_file_contents}  Get File  ${PHONEBOOK_JS_FILE}
  Set Global Variable  ${COURSE_JS_FILE_CONTENTS}  ${course_js_file_contents}
  Set Global Variable  ${PHONEBOOK_JS_FILE_CONTENTS}  ${phonebook_js_file_contents}