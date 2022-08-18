*** Settings ***
Library  ..${/}libraries${/}MyLibrary.py

# Here are general keywords shared by multiple tests
*** Keywords ***
End Testing
  Save Excel Document  ${CURDIR}${/}..${/}reports${/}DTEK2040_assessment_summary.xlsx
  Close Current Excel Document

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
  # sheet functions need to be tackled (or "hard calculated")
  ${sum_function}  Set Variable  =SUMMA(D4:AB4)
  Log  ${sum_function}
  Write Excel Cell  row_num=${student_row}  col_num=1  value=${id}
  Write Excel Cell  row_num=${student_row}  col_num=2  value=${sum_function}