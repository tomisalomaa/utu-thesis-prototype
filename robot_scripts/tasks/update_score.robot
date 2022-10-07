*** Settings ***
Library         OperatingSystem
Library         ExcelLibrary
Library         XML
Library         String
Library         Collections
Variables       ${GLOBAL_ROBO_VARIABLES_DIR}${/}common_variables.py
Resource        ${RESOURCES_DIR}${/}common_keywords.resource
Suite Setup     Open Report File
Suite Teardown  Close Report File

*** Variables ***
${REL_REPORTS_PATH}  ${REPORTS_DIR}${/}${EX_NUM}${/}

*** Tasks ***
Add Student To List
  [Tags]  new
  Insert Submission Id To Results Summary Sheet  ${STUDENT_REPORT_ROW}  ${STUDENT_ID}

Gather Results For ${STUDENT_ID}
  [Tags]  existing
  ${task_results}  Gather Results From Robot Log  ${STUDENT_OUTPUT}
  Set Global Variable  ${TASK_RESULTS}  ${task_results}

Update Task Results For ${STUDENT_ID}
  [Tags]  existing
  ${test_names}  Get Dictionary Keys  ${TASK_RESULTS}
  FOR  ${test}  IN  @{test_names}
    ${matching_cell}  Set Variable  ${FALSE}
    ${col}  Set Variable  ${3}
    ${row}  Set Variable  ${3}
    WHILE  True
      ${cell_content}  Read Excel Cell  row_num=${row}  col_num=${col}
      IF  '${cell_content}' == 'None'
        Log  Test name not found from report
        BREAK
      ELSE
        ${matching_cell}  Evaluate  '${test}' == '${cell_content}'
        IF  ${matching_cell}
          ${test_result}  Get From Dictionary  ${TASK_RESULTS}  ${test}
          IF  '${test_result}' == 'PASS'
            Write Excel Cell  row_num=${STUDENT_REPORT_ROW}  col_num=${col}  value=PASS
          ELSE
            Write Excel Cell  row_num=${STUDENT_REPORT_ROW}  col_num=${col}  value=FAIL
          END
          BREAK
        ELSE
          ${col}  Evaluate  ${col}+1
        END
      END
    END
  END

Calculate Current Total
  [Tags]  total
  ${col}  Set Variable  ${3}
  ${total_tasks_amount}  Set Variable  ${0}
  ${passed_tasks_amount}  Set Variable  ${0}
  ${total_score}  Set Variable  ${0}
  WHILE  True
    ${task_result}  Read Excel Cell  row_num=${STUDENT_REPORT_ROW}  col_num=${col}
    IF  '${task_result}' == 'PASS'
      ${total_tasks_amount}  Evaluate  ${total_tasks_amount}+1
      ${passed_tasks_amount}  Evaluate  ${passed_tasks_amount}+1
    ELSE IF  '${task_result}' == 'FAIL'
      ${total_tasks_amount}  Evaluate  ${total_tasks_amount}+1
    ELSE
      BREAK
    END
    ${col}  Evaluate  ${col}+1
  END
  ${total_score}  Evaluate  ${MAX_SCORE}*${passed_tasks_amount}/${total_tasks_amount}
  Write Excel Cell  row_num=${STUDENT_REPORT_ROW}  col_num=2  value=${total_score}

Save Report File
  [Tags]  new  existing  total
  Save Excel Document  filename=${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}

*** Keywords ***
Gather Results From Robot Log
  [Arguments]  ${student_output}
  &{test_result_dict}  Create Dictionary
  ${log_contents}  Get Elements  ${student_output}  .//test
  FOR  ${element}  IN  @{log_contents}
    ${test_name}  Get Element Attribute  ${element}  name
    ${test_name}  Fetch From Left  ${test_name}  :
    ${test_status}  Get Element Attribute  ${element}  status  ./status
    Set To Dictionary  ${test_result_dict}  ${test_name}  ${test_status}
  END
  [Return]  ${test_result_dict}