*** Settings ***
Library           ../libraries/MyLibrary.py

*** Variables ***
${IMAGE_COMPARATOR_COMMAND}   C:${/}ImageMagick-7.1.0-Q16-HDRI${/}magick.exe

# Here are general keywords shared by multiple tests
*** Keywords ***
Initiate Assessment Support
  [Arguments]  ${results_dir}
  Remove File  ${results_dir}DTEK2040_Part_0.xlsx
  Create Excel Document  doc_id=01
  Write Excel Cell  row_num=1  col_num=1  value=PART 0
  Write Excel Cell  row_num=3  col_num=2  value=TOTAL
  Write Excel Cell  row_num=2  col_num=3  value=HTML
  Write Excel Cell  row_num=3  col_num=4  value=Anchor element
  Write Excel Cell  row_num=3  col_num=5  value=Table
  Write Excel Cell  row_num=3  col_num=6  value=List
  Write Excel Cell  row_num=3  col_num=7  value=Image
  Write Excel Cell  row_num=3  col_num=8  value=Form with input
  Write Excel Cell  row_num=2  col_num=9  value=CSS
  Write Excel Cell  row_num=3  col_num=10  value=Hover
  Write Excel Cell  row_num=3  col_num=11  value=Specificity
  Write Excel Cell  row_num=3  col_num=12  value=Selectors
  Write Excel Cell  row_num=3  col_num=13  value=Position and size
  Save Excel Document  filename=${results_dir}DTEK2040_Part_0.xlsx

Clean Subject Folders
  [Arguments]  ${submissions_dir}
  Close All Excel Documents
  ${student_dirs}  List Directories In Directory  ${submissions_dir}
  FOR  ${dir}  IN  @{student_dirs}
    Remove Directory  ${submissions_dir}${dir}${/}  ${True}
  END

Insert Submission Id To Results Summary Sheet
  [Arguments]  ${student_row}  ${id}
  ${sum_function}  Set Variable  =SUMMA(D4:AB4)
  Log  ${sum_function}
  Write Excel Cell  row_num=${student_row}  col_num=1  value=${id}
  Write Excel Cell  row_num=${student_row}  col_num=2  value=${sum_function}

Save Task Score To Results Summary Sheet
  [Arguments]  ${student_row}  ${task_col}  ${score}
  ${score}  Convert To Number  ${score}
  Write Excel Cell  row_num=${student_row}  col_num=${task_col}  value=${score}
  Save Excel Document  filename=${results_dir}DTEK2040_Part_0.xlsx

# Compare Images
#    [Arguments]  ${Reference_Image_Path}  ${Test_Image_Path}  ${Allowed_Threshold}
#    ${TEMP}  Replace String  ${IMAGE_COMPARATOR_COMMAND}  __REFERENCE__  ${Reference_Image_Path}
#    ${COMMAND}  Replace String  ${TEMP}  __TEST__  ${Test_Image_Path}
#    ${RC}  ${OUTPUT}  Run And Return Rc And Output  ${COMMAND}
#    Log  ${OUTPUT}
#    ${RESULT}  Evaluate  ${OUTPUT} < ${Allowed_Threshold}
#    [Return]  ${RESULT}