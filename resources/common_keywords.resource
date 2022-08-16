*** Settings ***
Library  ..${/}libraries${/}MyLibrary.py

# Here are general keywords shared by multiple tests
*** Keywords ***
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

Search Local HTML Main Page Location
  [Arguments]  ${submission_dir}
  ${html_file_location}  Search File With Extension  ${submission_dir}  html
  [Return]  ${html_file_location}

Insert Submission Id To Results Summary Sheet
  [Arguments]  ${student_row}  ${id}
  ${sum_function}  Set Variable  =SUMMA(D4:AB4)
  Log  ${sum_function}
  Write Excel Cell  row_num=${student_row}  col_num=1  value=${id}
  Write Excel Cell  row_num=${student_row}  col_num=2  value=${sum_function}