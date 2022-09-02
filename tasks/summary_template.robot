*** Settings ***
Library  OperatingSystem
Library  ExcelLibrary
Variables  ..${/}variables${/}common_variables.py
Resource  ..${/}resources${/}common_keywords.resource

*** Variables ***
${REL_REPORTS_PATH}  ${CURDIR}${/}..${/}${REPORTS_DIR}${/}${EX_NUM}${/}

*** Tasks ***
Initiate Summarry File
  [Tags]  ex0  ex1  ex2  ex3
  Create Summarry Sheet Template  ${REL_REPORTS_PATH}  ${SUMMARY_FILE_NAME}  ${SUMMARY_FILE_ID}

Prepare Columns For Exercise 0
  [Tags]  ex0
  Create Columns EX0  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}

Prepare Columns For Exercise 1
  [Tags]  ex1
  Create Columns EX1  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}

Prepare Columns For Exercise 2
  [Tags]  ex2
  Create Columns EX2  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}

Prepare Columns For Exercise 3
  [Tags]  ex3
  Create Columns EX3  ${REL_REPORTS_PATH}${/}${SUMMARY_FILE_NAME}

Close Report
  [Tags]  ex0  ex1  ex2  ex3
  Close All Excel Documents

*** Keywords ***
Remove Existing Summary File
  [Arguments]  ${results_dir}
  ${result_files}  List Files In Directory  ${results_dir}
  Remove Files  @{result_files}

Create Summarry Sheet Template
  [Arguments]  ${results_dir}  ${summary_file_name}  ${document_id}
  Create Excel Document  doc_id=${document_id}
  Save Excel Document  filename=${results_dir}${summary_file_name}

Create Columns EX0
  [Arguments]  ${filename}
  Write Excel Cell  row_num=1  col_num=1  value=Exercise 0
  Write Excel Cell  row_num=3  col_num=2  value=TOTAL
  Write Excel Cell  row_num=2  col_num=3  value=HTML
  Write Excel Cell  row_num=3  col_num=3  value=E0-T1-1
  Write Excel Cell  row_num=2  col_num=4  value=Anchor element
  Write Excel Cell  row_num=3  col_num=4  value=E0-T1-2
  Write Excel Cell  row_num=2  col_num=5  value=Table
  Write Excel Cell  row_num=3  col_num=5  value=E0-T1-3
  Write Excel Cell  row_num=2  col_num=6  value=List
  Write Excel Cell  row_num=3  col_num=6  value=E0-T1-4
  Write Excel Cell  row_num=2  col_num=7  value=Image
  Write Excel Cell  row_num=3  col_num=7  value=E0-T1-5
  Write Excel Cell  row_num=2  col_num=8  value=Form with input
  Write Excel Cell  row_num=3  col_num=8  value=E0-T1-6
  Write Excel Cell  row_num=2  col_num=9  value=CSS
  Write Excel Cell  row_num=3  col_num=9  value=E0-T2-1
  Write Excel Cell  row_num=2  col_num=10  value=Hover
  Write Excel Cell  row_num=3  col_num=10  value=E0-T2-2
  Write Excel Cell  row_num=2  col_num=11  value=List and table styles
  Write Excel Cell  row_num=3  col_num=11  value=E0-T2-3
  Write Excel Cell  row_num=2  col_num=12  value=Specificity
  Write Excel Cell  row_num=3  col_num=12  value=E0-T2-4
  Write Excel Cell  row_num=2  col_num=13  value=Selectors
  Write Excel Cell  row_num=3  col_num=13  value=E0-T2-5
  Write Excel Cell  row_num=2  col_num=14  value=Position and size
  Write Excel Cell  row_num=3  col_num=14  value=E0-T2-6
  Save Excel Document  filename=${filename}

Create Columns EX1
  [Arguments]  ${filename}
  Write Excel Cell  row_num=1  col_num=1  value=Exercise 1
  Write Excel Cell  row_num=3  col_num=2  value=TOTAL
  Write Excel Cell  row_num=1  col_num=3  value=COURSES APP
  Write Excel Cell  row_num=2  col_num=3  value=Three main components
  Write Excel Cell  row_num=3  col_num=3  value=E1-T1-1
  Write Excel Cell  row_num=2  col_num=4  value=Part components within Contents
  Write Excel Cell  row_num=3  col_num=4  value=E1-T1-2
  Write Excel Cell  row_num=2  col_num=5  value=Object data
  Write Excel Cell  row_num=3  col_num=5  value=E1-T1-3
  Write Excel Cell  row_num=2  col_num=6  value=Props are passed directly
  Write Excel Cell  row_num=3  col_num=6  value=E1-T1-4
  Write Excel Cell  row_num=2  col_num=7  value=App opens in a browser
  Write Excel Cell  row_num=3  col_num=7  value=E1-T1-5
  Write Excel Cell  row_num=1  col_num=8  value=FEEDBACK APP
  Write Excel Cell  row_num=2  col_num=8  value=Three feedback buttons
  Write Excel Cell  row_num=3  col_num=8  value=E1-T2-1
  Write Excel Cell  row_num=2  col_num=9  value=Statistics are hidden if no feedback
  Write Excel Cell  row_num=3  col_num=9  value=E1-T2-2
  Write Excel Cell  row_num=2  col_num=10  value=App contains several components
  Write Excel Cell  row_num=3  col_num=10  value=E1-T2-3
  Write Excel Cell  row_num=2  col_num=11  value=App displays and updates statistics
  Write Excel Cell  row_num=3  col_num=11  value=E1-T2-4
  Write Excel Cell  row_num=2  col_num=12  value=Statistics are presented in html table
  Write Excel Cell  row_num=3  col_num=12  value=E1-T2-5
  Save Excel Document  filename=${filename}

Create Columns EX2
  [Arguments]  ${filename}
  Write Excel Cell  row_num=1  col_num=1  value=Exercise 2
  Write Excel Cell  row_num=3  col_num=2  value=TOTAL
  Write Excel Cell  row_num=1  col_num=3  value=COURSES APP
  Write Excel Cell  row_num=2  col_num=3  value=Content structuring
  Write Excel Cell  row_num=3  col_num=3  value=E2-T1-1
  Write Excel Cell  row_num=2  col_num=4  value=Exercises total number is displayed
  Write Excel Cell  row_num=3  col_num=4  value=E2-T1-2
  Write Excel Cell  row_num=2  col_num=5  value=Module separation
  Write Excel Cell  row_num=3  col_num=5  value=E2-T1-3
  Write Excel Cell  row_num=1  col_num=6  value=PHONEBOOK APP
  Write Excel Cell  row_num=2  col_num=6  value=Prevent adding already existing name
  Write Excel Cell  row_num=3  col_num=6  value=E2-T2-1
  Write Excel Cell  row_num=2  col_num=7  value=App is divided into several components
  Write Excel Cell  row_num=3  col_num=7  value=E2-T2-2
  Write Excel Cell  row_num=2  col_num=8  value=Contact can be deleted
  Write Excel Cell  row_num=3  col_num=8  value=E2-T2-3
  Write Excel Cell  row_num=2  col_num=9  value=Initial state is stored in a file
  Write Excel Cell  row_num=3  col_num=9  value=E2-T2-4
  Write Excel Cell  row_num=2  col_num=10  value=Initial state is fetched from server
  Write Excel Cell  row_num=3  col_num=10  value=E2-T2-5
  Save Excel Document  filename=${filename}

Create Columns EX3
  [Arguments]  ${filename}
  Write Excel Cell  row_num=1  col_num=1  value=Exercise 3
  Write Excel Cell  row_num=3  col_num=2  value=TOTAL
  Write Excel Cell  row_num=2  col_num=3  value=Hello World
  Save Excel Document  filename=${filename}