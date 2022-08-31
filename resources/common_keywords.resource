*** Settings ***
Library  ..${/}libraries${/}MyLibrary.py
Variables  ..${/}variables${/}common_variables.py

# Here are general keywords shared by multiple tests
*** Keywords ***
Open Report File
  Open Excel Document  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}  doc01

Close Report File
  Close All Excel Documents

Clean Subject Folders
  [Arguments]  ${submissions_dir}
  Close All Excel Documents
  ${student_dirs}  List Directories In Directory  ${submissions_dir}
  FOR  ${dir}  IN  @{student_dirs}
    Remove Directory  ${submissions_dir}${dir}${/}  ${True}
  END

Save Task Score To Results Summary Sheet
  [Arguments]  ${student_row}  ${task_col}  ${score}
  ${score}  Convert To Number  ${score}
  Write Excel Cell  row_num=${student_row}  col_num=${task_col}  value=${score}
  Save Excel Document  filename=${results_dir}DTEK2040_Part_0.xlsx

Get File With Most Lines
  [Arguments]  ${files}
  ${line_count}  Set Variable  ${0}
  ${result_file}  Set Variable  ${files}[0]
  FOR  ${file}  IN  @{files}
    ${file_content}  Get File  ${file}
    ${new_line_count}  Get Line Count  ${file_content}
    IF  ${line_count} < ${new_line_count}
      ${line_count}  Set Variable  ${new_line_count}
      ${result_file}  Set Variable  ${file}
    END
  END
  [Return]  ${result_file}

Search Local HTML Main Page Location
  # Heuristic assumes largest line count will be (the "correct") index file
  [Arguments]  ${submission_dir}
  ${html_file_locations}  Search File With Extension  ${submission_dir}  html
  ${html_file}  Get File With Most Lines  ${html_file_locations}
  [Return]  ${html_file}

Insert Submission Id To Results Summary Sheet
  [Arguments]  ${student_row}  ${id}
  Write Excel Cell  row_num=${student_row}  col_num=1  value=${id}

Find Files With Content Containing Keywords
  [Arguments]  ${parent_search_dir}  ${required_keywords}  ${file_extension}
  @{result_files}  Create List
  ${files}  Search File With Extension  ${parent_search_dir}  ${file_extension}
  FOR  ${file}  IN  @{files}
    ${keyword_present}  Set Variable  'EMPTY'
    ${file_contents}  Get File  ${file}
    FOR  ${word}  IN  @{required_keywords}
      ${keywords_found}  Get Regexp Matches  ${file_contents}  (?i:.*?${word}*.*?)
      ${amount_found}  Get Length  ${keywords_found}
      IF  ${amount_found} == ${0}
        BREAK
      ELSE
        Append To List  ${result_files}  ${file}
      END
    END
  END
  [Return]  ${result_files}

Determine Most Recently Modified
  [Arguments]  ${list_of_files}
  ${base_time}  Set Variable  ${0}
  ${recent_file}  Set Variable  None
  FOR  ${file}  IN  @{list_of_files}
    ${time}  Get Modified Time  ${file}  epoch
    IF  ${time} > ${base_time}
      ${base_time}  Set Variable  ${time}
      ${recent_file}  Set Variable  ${file}
    END
  END
  [Return]  ${recent_file}

Find Most Recent File Based On Keywords
  [Arguments]  ${location}  ${keywords}  ${file_extension}
  ${files}  Find Files With Content Containing Keywords  ${location}  ${keywords}  ${file_extension}
  ${most_recent_file}  Determine Most Recently Modified  ${files}
  [Return]  ${most_recent_file}

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

Verify Table Elements
  [Arguments]  ${table_elements}
  ${table_elem_regex}  Set Variable  table|caption|colgroup|thead|tbody|tr|th|td|tfoot
  ${proper_table_amount}  Set Variable  ${0}
  FOR  ${table}  IN  @{table_elements}
    @{elements}  Split String  ${table}  ${SPACE}
    FOR  ${element}  IN  @{elements}
      ${is_table_element}  Run Keyword And Return Status
      ...  Should Match Regexp  ${element}  ${table_elem_regex}
      IF  '${is_table_element}' != 'PASS'
        Remove Values From List  ${elements}  ${element}
      END
    END
    &{relations}  Parent Child Relations From List  ${elements}
    ${verification_result}  Run Keyword And Return Status
    ...  Verify Table Element Hierarchy  ${relations}
    IF  ${verification_result}
      ${proper_table_amount}  Evaluate  ${proper_table_amount} + 1
    END
  END
  [Return]  ${proper_table_amount}