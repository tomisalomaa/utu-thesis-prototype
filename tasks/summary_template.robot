*** Settings ***
Library  OperatingSystem
Library  ExcelLibrary
Variables  ..${/}variables${/}common_variables.py
Resource  ..${/}resources${/}common_keywords.resource

*** Variables ***
${REL_REPORTS_PATH}  ${CURDIR}${/}..${/}${REPORTS_DIR}
${SUMMARY_FILE_NAME}  DTEK2040_assessment_summary
${SUMMARY_FILE_ID}  doc1

*** Tasks ***
Initiate Summarry File
  Create Summarry Sheet Template  ${REL_REPORTS_PATH}  ${SUMMARY_FILE_NAME}  ${SUMMARY_FILE_ID}

Prepare Columns For Exercise 0
  Create Columns for Exercise 0  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}

*** Keywords ***
Remove Existing Summary File
  [Arguments]  ${results_dir}
  ${result_files}  List Files In Directory  ${results_dir}
  Remove Files  @{result_files}

Create Summarry Sheet Template
  [Arguments]  ${results_dir}  ${summary_file_name}  ${document_id}
  Create Excel Document  doc_id=${document_id}
  Save Excel Document  filename=${results_dir}${summary_file_name}.xlsx

Create Columns for Exercise 0
  [Arguments]  ${filename}
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
  Save Excel Document  filename=${filename}.xlsx