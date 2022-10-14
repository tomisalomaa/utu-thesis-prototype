# Common keywords contain keywords that are used or have potential to be used
# by multiple robot files now or in the future development.

*** Settings ***
Library  ..${/}libraries${/}MyLibrary.py
Variables  ..${/}variables${/}common_variables.py

*** Keywords ***
# Opens the summary report file using common variables.
# Using the keyword does not require inputs but the values for report path and
# summary file name in common_variables.py need to respect the project structure.
# File needs to be found for the keyword to PASS.
# @output: summary file is opened with id 'doc01'
Open Report File
  Open Excel Document  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}  doc01

# Iterates through a list of files and compares their line count.
# @input:   ${files}        a list of file paths
# @returns: ${result_file}  file path of the file containing most lines
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

# Searches a directory by using a keyword defined in MyLibrary.
# The search returns all .html file paths from that directory.
# From the returned list of file paths, the html file with most lines is chosen.
# @input:   ${submission_dir}     directory path containing the wanted html file
# @returns: ${html_file}        file path of the html file containing most lines
Search Local HTML Main Page Location
  [Arguments]  ${submission_dir}
  ${html_file_locations}  Search File With Extension  ${submission_dir}  html
  ${html_file}  Get File With Most Lines  ${html_file_locations}
  [Return]  ${html_file}

# Respects the current design of results summary sheet and inserts the given submission id
# into the first column of the template.
# @input: ${student_row}    row number of the submission in summary sheet,
#         ${id}             id given to the submission
# @output: writes id into the summary sheet cell at column=1, row=given
Insert Submission Id To Results Summary Sheet
  [Arguments]  ${student_row}  ${id}
  Write Excel Cell  row_num=${student_row}  col_num=1  value=${id}

# Searches in a given directory for files with a given extension that contain given keywords.
# All the declared keywords must be found from the contents of a file in order to determine that
# the file be returned. If a even a single word is not found from contents, the file will be discarded.
# Keywords are treated as patterns. This means, for example, that given an input keyword 'light',
# a match is found from contents including 'lightning', 'blight', 'lighter', ...
# Patterns are also treated case insensitively.
# @input:     ${parent_search_dir}    directory path to search files from
#             ${required_keywords}    a list of keywords to be pattern matched within file contents
#             ${file_extension}       extension to determine what files should be considered while searching,
#                                     example: js html
# @returns:   ${result_files}         a list of files that have positive matches from each and every input keyword
Find Files With Content Containing Keywords
  [Arguments]  ${parent_search_dir}  ${required_keywords}  ${file_extension}
  ${keywords_amount}  Get Length  ${required_keywords}
  @{result_files}  Create List
  ${files}  Search File With Extension  ${parent_search_dir}  ${file_extension}
  FOR  ${file}  IN  @{files}
    ${total_found}  Set Variable  ${0}
    ${file_contents}  Get File  ${file}
    FOR  ${word}  IN  @{required_keywords}
      ${matches_found}  Get Regexp Matches  ${file_contents}  (?i:.*?${word}*.*?)
      ${amount_found}  Get Length  ${matches_found}
      IF  ${amount_found} == ${0}
        BREAK
      ELSE
        ${total_found}  Evaluate  ${total_found}+1
      END
      IF  ${total_found} == ${keywords_amount}
        Append To List  ${result_files}  ${file}
      END
    END
  END
  [Return]  ${result_files}

# Uses 'Get Modified Time' from OperatingSystem library to compare which of the input files
# is most recently modified. Keyword is used with 'epoch' option which means the modification
# time of a file is returned in seconds after the UNIX epoch.
# Use of this keyword required the robot file to import the OperatingSystem library.
# @input:     ${list_of_files} a list of file paths to compare
# @returns:   ${recent_file} file path of the most recently modified file
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

# See 'Find Files With Content Containing Keywords' and
# 'Determine Most Recently Modified' keywords above.
# Uses the results of afore mentioned keyword as input for the latter.
# @input:   ${location}             directory path to search files from
#           ${keywords}             a list of keywords to be pattern matched within file contents
#           ${file_extension}       extension to determine what files should be considered while searching,
#                                   example: js html
# @returns:   ${most_recent_file}   file path of the most recently modified file
Find Most Recent File Based On Keywords
  [Arguments]  ${location}  ${keywords}  ${file_extension}
  ${files}  Find Files With Content Containing Keywords  ${location}  ${keywords}  ${file_extension}
  ${most_recent_file}  Determine Most Recently Modified  ${files}
  [Return]  ${most_recent_file}

# See 'Find Files With Content Containing Keywords' and
# 'Determine Most Recently Modified' keywords above.
# Uses the results of afore mentioned keyword as input for the latter.
# Further filters the results by only considering files that fit the name requirement.
# @input:   ${location}             directory path to search files from
#           ${keywords}             a list of keywords to be pattern matched within file contents
#           ${name}                 expected file name without an extension
#           ${file_extension}       extension to determine what files should be considered while searching,
#                                   example: js html
# @returns:   ${most_recent_file}   file path of the most recently modified file
Find Most Recent File Based On Keywords And Name
  [Arguments]  ${location}  ${keywords}  ${name}  ${file_extension}
  ${all_files}  Find Files With Content Containing Keywords  ${location}  ${keywords}  ${file_extension}
  @{files}  Create List
  FOR  ${file}  IN  @{all_files}
    ${directory}  ${file_name}  Split String From Right  ${file}  /  1
    ${file_name}  Convert To Lower Case  ${file_name}
    IF  '${file_name}' == '${name}.${file_extension}'
      Append To List  ${files}  ${file}
    END
  END
  ${most_recent_file}  Determine Most Recently Modified  ${files}
  [Return]  ${most_recent_file}

# The keyword takes parent element:child element key:value pairs as input and goes through
# each key to verify that child elements are as dictated by web standards.
# If at any point a child element is found to be incorrectly under a certain parent element,
# the keyword determines FAIL status and acts as a test case would when keyword fails.
# This keyword can be used together with 'Run Keyword And Return Status' to catch the status
# as a variable without failing a task / test.
# @input:   ${parent_child_dict}    a dictionary where keys are parent elements and values the child elements found under that parent
# @output:  PASS / FAIL status
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

# Uses regular expression to verify that a table element does not contain other than hierarchically
# correct child elements. The keyword can take a list of found table elements. This keyword does not produce
# a PASS / FAIL status but rather the number of verifiably correct tables.
# @input:     ${table_elements}       a list of table elements
# @output:    ${proper_table_amount}  number of correctly constructed table elements
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