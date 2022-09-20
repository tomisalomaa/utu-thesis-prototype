*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         RequestsLibrary
Library         ..${/}libraries${/}MyLibrary.py
Variables       ..${/}variables${/}common_variables.py
Resource        ..${/}resources${/}common_keywords.resource
Suite Setup     Initiate Dynamic Testing
Suite Teardown  Close Page

*** Test Cases ***
E1-T1-5: Browsing The Course App
  [Documentation]  App functions in browser as expected:
  ...  course name, parts and total info is rendered.
  [Tags]  e1t1
  GET  ${REACT_APP_ADDR}
  Take Screenshot  filename=${STUDENT_ID}

E1-T2-1: Feedback App Contains Three Buttons
  [Documentation]  App includes three feedback buttons:
  ...  good (hyvä),
  ...  neutral (neutraali) and
  ...  poor (huono)
  [Tags]  e1t2
  @{expected_button_content}  Create List  hyvä  neutraali  huono  good  neutral  bad
  ${buttons}  Get Elements  xpath=//button
  FOR  ${button}  IN  @{buttons}
    ${content}  Get Property  ${button}  innerText
    ${content}  Convert To Lower Case  ${content}
    Should Contain Any  ${content}  @{expected_button_content}
    Remove Values From List  ${expected_button_content}  ${content}
  END

E1-T2-2: Feedback App Statistics Are Hidden When Empty
  [Documentation]  Statistics should only be displayed when user has given feedback.
  [Tags]  e1t2
  # Note: this test case and the next one will always run in the same suite;
  # if this one passes prior to running t2-4, and then the t2-4 passes,
  # that means the statistics were not available here but they became availabe
  # in the next case as we continued with the same browser session.
  Get Element Count  xpath=//*[text() = '0']  ==  0
  Get Element Count  xpath=//*[text() = 'average']  ==  0
  Get Element Count  xpath=//*[text() = 'keskiarvo']  ==  0

E1-T2-4: Feedback App Displays Statistics
  [Documentation]  App displays a statistics section that corresponds with
  ...  the button interactions.
  ...  Statistics include 1) the amounts of individual button pushes,
  ...  2) average (where good is valued 1, neutral is valued 0 and poor is valued -1)
  ...  and 3) the percentage of positive votes.
  [Tags]  e1t2
  ${button_good}  Get Element  xpath=//button[text() = 'hyvä']|//button[text() = 'Hyvä']|//button[text() = 'good']|//button[text() = 'Good']
  ${button_neutral}  Get Element  xpath=//button[text() = 'neutraali']|//button[text() = 'Neutraali']|//button[text() = 'neutral']|//button[text() = 'Neutral']
  ${button_bad}  Get Element  xpath=//button[text() = 'huono']|//button[text() = 'Huono']|//button[text() = 'bad']|//button[text() = 'Bad']
  Click  ${button_good}
  # Statistics should contain...
  # good: 1 & average: 1
  Get Element Count  xpath=//*[text() = '1']  ==  2
  # neutral: 0 & bad: 0
  Get Element Count  xpath=//*[text() = '0']  ==  2
  # positives percentage: 100
  Get Element Count  xpath=//*[text() = '100']  ==  1
  Click  ${button_good}
  Click  ${button_good}
  # Statistics should contain...
  # good: 3 & average: 1
  Get Element Count  xpath=//*[text() = '3']  ==  1
  Get Element Count  xpath=//*[text() = '1']  ==  1
  # neutral: 0 & bad: 0
  Get Element Count  xpath=//*[text() = '0']  ==  2
  # positives percentage: 100
  Get Element Count  xpath=//*[text() = '100']  ==  1
  Click  ${button_bad}
  # Statistics should contain...
  # good: 3 & average: 0.5
  Get Element Count  xpath=//*[text() = '3']  ==  1
  Get Element Count  xpath=//*[text() = '0.5']  ==  1
  # neutral: 0 & bad: 1
  Get Element Count  xpath=//*[text() = '0']  ==  1
  Get Element Count  xpath=//*[text() = '1']  ==  1
  # positives percentage: 75
  Get Element Count  xpath=//*[text() = '75']  ==  1
  Click  ${button_neutral}
  Click  ${button_neutral}
  Click  ${button_neutral}
  Click  ${button_neutral}
  # Statistics should contain...
  # good: 3 & average: 0.25
  Get Element Count  xpath=//*[text() = '3']  ==  1
  Get Element Count  xpath=//*[text() = '0.25']  ==  1
  # neutral: 4 & bad: 1
  Get Element Count  xpath=//*[text() = '4']  ==  1
  Get Element Count  xpath=//*[text() = '1']  ==  1
  # positives percentage: 37.5
  Get Element Count  xpath=//*[text() = '37.5']  ==  1

E1-T2-5: Feedback App Statistics Contents Are In HTML Table
  [Documentation]  Statistics should be shown as an html table.
  ...  The table should be properly constructed / organized in terms of
  ...  element hierarchy.
  [Tags]  e1t2
  # Note: as this is the final test case of the suite, the browser state
  # is as it is left in the previous test case: statistics are present.
  # As such the actual updating of values would already be verified through
  # completing the previous two test cases. If this test case needs to be
  # entirely atomic, then the manipulation of feedback would also
  # need to be added as a test part here. Now, however, we will consider
  # cases as a suite as this will be included in any and all tags with
  # the required pre-tests to achieve the necessary state of visible feedback.
  ${table_elements}  Get Elements  xpath=//table
  ${number_of_proper_tables}  Verify Table Elements  ${table_elements}
  IF  ${number_of_proper_tables} == 0
    Fail  No table elements or table elements with proper hierarchy found
  END

*** Keywords ***
Initiate Dynamic Testing
  Log  ${TEST_SUBJECT_DIR}
  New Page  ${REACT_APP_ADDR}