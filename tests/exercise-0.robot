# Robot Framework Base Project
# run: robot -d results -i test1 tests/tests.robot

# Here are test settings
*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         ArchiveLibrary
Library         ExcelLibrary
Library           ../libraries/MyLibrary.py
Resource        ${RESOURCES_DIR}common_keywords.resource
Suite Setup     Initiate Assessment Support  ${RESULTS_DIR}
Suite Teardown  Clean Subject Folders  ${TEST_SUBJECTS_DIR}
# Test Setup
# Test Teardown

# Here are test case specific variables
*** Variables ***
${RESOURCES_DIR}  D:${/}koodi${/}diplomi${/}rf-base-project${/}resources${/}
${SUBMISSIONS_DIR}  D:${/}koodi${/}diplomi${/}rf-base-project${/}data${/}submissions${/}
${TEST_SUBJECTS_DIR}  D:${/}koodi${/}diplomi${/}rf-base-project${/}data${/}test-subjects${/}
${RESULTS_DIR}  D:${/}koodi${/}diplomi${/}rf-base-project${/}results${/}
${student_score_row}  ${3}

# Here are test cases
*** Test Cases ***
Test case 1
  [Documentation]  Test 1 documentation
  [Tags]    test1
  Extract Submission Zip  ${SUBMISSIONS_DIR}
  ${subject_dirs}  List Directories In Directory  ${TEST_SUBJECTS_DIR}
  FOR  ${directory}  IN  @{subject_dirs}
    ${html_file}  Search Local HTML Main Page Location  ${TEST_SUBJECTS_DIR}${directory}${/}
    ${css_file}  Search File With Extension  ${TEST_SUBJECTS_DIR}${directory}${/}  css
    ${student_score_row}  Evaluate  ${student_score_row} + 1
    Insert Submission Id To Results Summary Sheet  ${student_score_row}  ${directory}
    New Page  ${html_file}
    # Kuvakaappaukset pitää saada osaksi summarya?
    # Menee tällä hetkellä results\browser\screenshot\
    Take Screenshot  filename=${directory}
    Page Contains An Anchor Element  ${student_score_row}
    Page Has A Table  ${student_score_row}
    Page Has A List  ${student_score_row}
    Page Contains An Image  ${student_score_row}
    Page Has A Form With Input Elements  ${student_score_row}

    Anchor Has Hover Style  ${css_file}

    Close Page
  END
  Close Browser

# Here are test case specific keywords
*** Keywords ***
Extract Submission Zip
  [Arguments]  ${submissions_dir}
  ${files}  List Files In Directory  ${submissions_dir}
  FOR  ${file}  IN  @{files}
    ${filename}  Fetch From Left  ${file}  .
    Extract Zip File  ${submissions_dir}${file}  ${CURDIR}${/}..${/}data${/}test-subjects${/}${filename}${/}
  END

Search Local HTML Main Page Location
  [Arguments]  ${submission_dir}
  ${html_file_location}  Search File With Extension  ${submission_dir}  html
  [Return]  ${html_file_location}

Page Contains An Anchor Element
  [Arguments]  ${student_row}
  ${anchor}  Get Attribute  xpath=(//a)[1]  href
  Log  ${anchor}
  IF  '${anchor}' != '${EMPTY}'
    Save Task Score To Results Summary Sheet  ${student_row}  4  0.2
  ELSE
    Save Task Score To Results Summary Sheet  ${student_row}  4  0
  END

Page Has A Table
  [Arguments]  ${student_row}
  ${tables}  Get Element Count  xpath=(//table)
  Log  ${tables}
  IF  ${tables} > 0
    Save Task Score To Results Summary Sheet  ${student_row}  5  0.2
  ELSE
    Save Task Score To Results Summary Sheet  ${student_row}  5  0
  END

Page Has A List
  [Arguments]  ${student_row}
  ${unordered}  Get Element Count  xpath=(//ul)
  ${ordered}  Get Element Count  xpath=(//ol)
  ${lists}  Evaluate  ${unordered} + ${ordered}
  Log  '${lists}'
  IF  ${lists} > 0
    Save Task Score To Results Summary Sheet  ${student_row}  6  0.2
  ELSE
    Save Task Score To Results Summary Sheet  ${student_row}  6  0
  END

Page Contains An Image
  [Arguments]  ${student_row}
  ${images}  Get Element Count  xpath=(//img)
  Log  '${images}'
  IF  ${images} > 0
    Save Task Score To Results Summary Sheet  ${student_row}  7  0.2
  ELSE
    Save Task Score To Results Summary Sheet  ${student_row}  7  0
  END

Page Has A Form With Input Elements
  [Arguments]  ${student_row}
  ${forms}  Get Element Count  xpath=(//form)  >  0
  IF  ${forms} > 0
    ${inputs}  Get Element Count  xpath=(//form//input)
    IF  ${inputs} > 0
      Save Task Score To Results Summary Sheet  ${student_row}  8  0.2
      Log  Form with inputs found
    ELSE
      Save Task Score To Results Summary Sheet  ${student_row}  8  0
    END
  ELSE
    Fail  No form elements found
  END

Anchor Has Hover Style
  [Arguments]  ${css_file_location}
  File Should Exist  ${css_file_location}
  ${css_file_contents}  Grep File  ${css_file_location}  *
  @{css_file_contents}  Split To Lines  ${css_file_contents}
  @{css_style_definitions}  Create List
  FOR  ${line}  IN  @{css_file_contents}
    ${contains}  Evaluate   '{' in '''${line}'''
    IF  ${contains}
      Append To List  ${css_style_definitions}  ${line}
    END
  END
  Log  ${css_style_definitions}

#   # Etsi kaikki ankkurit
#   ${anchor_elements}  Get Elements  xpath=//A
#   # Käy läpi jokainen ankkuri ja tarkasta määritellyt tyylit
#   FOR  ${anchor}  IN  @{anchor_elements}
#     ${applied_styles}  Get Style   ${anchor}
#     Log  ${applied_styles}
#   END
#   # Tarkasta löytyykö ankkurista hover määrittelyä