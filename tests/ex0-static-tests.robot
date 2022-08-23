*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         RequestsLibrary
Library         ExcelLibrary
Library         ..${/}libraries${/}MyLibrary.py
Variables       ..${/}variables${/}common_variables.py
Resource        ..${/}resources${/}common_keywords.resource
Suite Setup     Initiate Static Testing

*** Test Cases ***
E0-T1-1: Verify Html Anatomy
  [Documentation]  Submission includes a valid html index page.
  ...  Validity is determined by verifying the following contents:
  ...  - Doctype declaration as html
  ...  - Contains <html></html> element
  ...  - Html element contains <head></head> element within
  ...  - Html element contains <body></body> element within
  ...  Passing this assessment is mandatory for scoring in E0.
  [Tags]  ex0  e0t1  full
  
  # Check source code for elements: html, head, body
  ${html_contents}  Get File  ${HTML_FILE}
  # Open a browser session with the static html page
  New Page  file://${HTML_FILE}
  # Take a screenshot of the page for records and added transparency / visibility
  Take Screenshot  filename=${STUDENT_ID}
  # With above steps the test case verifies that the file could function as a valid
  # static page when viewed on a browser.
  Close Page
  # Verify html, head and body elements and the doctype declaration
  ${html_element}  Get Regexp Matches  ${html_contents}  <html>|<\\/html>
  ${head_element}  Get Regexp Matches  ${html_contents}  <head>|<\\/head>
  ${body_element}  Get Regexp Matches  ${html_contents}  <body>|<\\/body>
  ${doctype}  Get Regexp Matches  ${html_contents}  <!DOCTYPE html>
  Should Not Be Empty  ${html_element}
  Should Not Be Empty  ${head_element}
  Should Not Be Empty  ${body_element}
  Should Not Be Empty  ${doctype}

E0-T1-2: Page contains a valid anchor element
  [Documentation]  Page should have at least one anchor elment with a href attribute.
  ...  The requirements for href are not set; the href attribute can be even
  ...  declared empty (href="") which by w3 specification is a valid href pointing
  ...  to the document itself.
  ...  Requirements do not place assessment burden on whether the links are broken
  ...  or not or which types of links are created and thus no such assessments
  ...  are included in this test case for functionality.
  [Tags]  ex0  e0t1  full

  # Find anchor elements and their href attributes from source
  ${anchor_href_data}  Find Elements With Attribute  ${HTML_FILE}  a  href
  # Verify at least one anchor element with a href attribute is found
  Should Not Be Empty  ${anchor_href_data}

E0-T1-3: Page contains a valid table element
  [Documentation]  Page has at least one table element that contains proper child elements.
  ...  The hierarchy of table elements is considered to be:
  ...
  ...  1) <table> encapsulates all the table child-elements
  ...  2) <caption> is directly under <table> 
  ...  2) <colgroup> is directly under <table>
  ...  2) <thead> is directly under <table>
  ...  2) <tbody> is directly under <table> and encapsulates <tr> elements
  ...  3) <tr> is directly under <tbody> and encapsulates <th> and <td> elements
  ...  4) <th> is directly under <tr>
  ...  4) <td> is directly under <tr>
  ...  2) <tfoot> is directly under <table>
  ...
  ...  All elements need not be included within a table but if they are
  ...  then the relation between these elements should be as presented.
  ...  If <tbody> is not used then <tr> can be used directly under <table>.
  [Tags]  ex0  e0t1  full

  # Find table elements from the raw html file
  ${table_elements}  Find Elements From Raw Source  ${html_file}  table
  # Validate table hierarchy of each table
  ${number_of_proper_tables}  Verify Table Elements  ${table_elements}
  # Verify at least one table passed the structure test.
  Should Be True  ${number_of_proper_tables} > 0

E0-T1-4: Page contains a valid list element
  [Documentation]  Page has at least one list element that contains proper child elements.
  ...  Lists in html can be defined as <ul>, <menu> (semantic alternative to <ul>) or <ol>.
  ...  Approved direct children for the mentioned list elements are:
  ...  <li>, <script>, <template>
  ...  A list needs to contain at least one or more of these child elements.
  [Tags]  ex0  e0t1  full

  ${number_of_proper_lists}  Set Variable  ${0}
  ${ul_elements}  Find Elements From Raw Source  ${html_file}  ul
  ${ol_elements}  Find Elements From Raw Source  ${html_file}  ol
  ${menu_elements}  Find Elements From Raw Source  ${html_file}  menu
  ${number_of_proper_ul}  Verify List Elements  ${ul_elements}
  ${number_of_proper_ol}  Verify List Elements  ${ol_elements}
  ${number_of_proper_menu}  Verify List Elements  ${menu_elements}
  ${number_of_proper_lists}  Evaluate  ${number_of_proper_ul} + ${number_of_proper_ol} + ${number_of_proper_menu}
  Should Be True  ${number_of_proper_lists} > 0

E0-T2-1: CSS file exists and it is referred in the index html file
  [Documentation]    Search for a css file within the submitted materials.
  ...    Verify it is being referred inside the header section of index html file.
  [Tags]  ex0  e0t2  full

  ${css_file_dir}  ${css_file_name}  Split String From Right  ${CSS_FILE}  ${/}  max_split=1
  ${html_file_contents}  Get File  ${HTML_FILE}
  ${css_link}  Get Regexp Matches  ${html_file_contents}  <\s*?link.*?rel="stylesheet".*?>
  Should Match Regexp  ${css_link}[0]  href\\s*?=\\s*?".*?${css_file_name}\\s*?"

E0-T2-2: Hover style defined
  [Documentation]  Hover styling for an anchor element is verifiably implemented.
  ...  Includes assumptions:
  ...  1) Styling needs to refer or be used on an anchor element;
  ...     simply defining hover style is not enough.
  ...  2) Most cases to test will follow study material and the referred Mozilla tutorial;
  ...     most popular ways to define the style will be a:hover and a.class-ref:hover.
  [Tags]  ex0  e0t2  full

  ${css_file_contents}  Get File  ${CSS_FILE}
  ${hover_styles}  Get Regexp Matches  ${css_file_contents}  \s*?a:hover|\s*?a\..*?:hover
  ${ahover_is_in_list}  Evaluate  'a:hover' in ${hover_styles}
  IF  not ${ahover_is_in_list}
    ${class_name}  Get Regexp Matches  ${style}  \.(.*?):  1
    ${class_name}  Strip String  ${class_name}[0]  characters=.
    ${class_matches}  Find Elements By Class  ${HTML_FILE}  a  ${class_name}
    Should Be True  ${class_matches}
  ELSE
    Should Be True  ${hover_styles}
  END

E0-T2-3: List and table styles are defined
  [Documentation]  Styles are defined for lists and tables.
  ...  Additionally the tasker requires the use of classes and
  ...  ids to define styles; Past assessments have, however,
  ...  given full scores even if tables and lists specifically
  ...  do not use class or id declarations to define their styles.
  ...  Also, accepted examples have contained submissions that
  ...  do not style the <table> or <ol>/<ul> elements but rather
  ...  their child elements to come up with the stylizations.
  ...
  ...  Thus checking for the use of styles and classes for styling
  ...  is a test case of it's own.
  ...  Use of these declarations still need to be checked in scope of
  ...  tables and lists here because there is a possibility they are
  ...  used instead of generally styling the elements.
  [Tags]  ex0  e0t2  full

  @{table_ids}  Create List
  @{table_classes}  Create List
  @{list_ids}  Create List
  @{list_classes}  Create List
  # Gather table elements from html file
  ${table_elements}  Find Elements From Html  ${HTML_FILE}  table
  ${table_ids}  Store Id References  ${table_elements}
  ${table_classes}  Store Class References  ${table_elements}
  # Gather list elements from html file
  ${ul_list_elements}  Find Elements From Html  ${HTML_FILE}  ul
  ${ol_list_elements}  Find Elements From Html  ${HTML_FILE}  ol
  ${menu_list_elements}  Find Elements From Html  ${HTML_FILE}  menu
  @{all_list_elements}  Create List  @{ul_list_elements}  @{ol_list_elements}  @{menu_list_elements}
  ${list_ids}  Store Id References  ${all_list_elements}
  ${list_classes}  Store Class References  ${all_list_elements}
  # Verify defined table styles
  ${css_file_contents}  Get File  ${CSS_FILE}
  ${table_styles_found}  Verify Defined Table Styles  ${css_file_contents}  ${table_ids}  ${table_classes}
  # Verify defined list styles
  ${list_styles_found}  Verify Defined List Styles  ${css_file_contents}  ${list_ids}  ${list_classes}
  Should Be True  ${table_styles_found}
  Should Be True  ${list_styles_found}

E0-T2-5: Id and class selector are used
  [Documentation]  Ids and class selectors are used to define styles.
  ...  The test deduces whether at least one id and one class definition
  ...  corresponding to a html element is found and has content in the CSS
  ...  file.
  [Tags]  ex0  e0t2  full

  ${html_contents}  Get File  ${HTML_FILE}
  ${html_ids}  Get Regexp Matches  ${html_contents}  .*?id\\s*?=\\s*?["|'](.*?)["|']  1
  ${html_classes}  Get Regexp Matches  ${html_contents}  .*?class\\s*?=\\s*?["|'](.*?)["|']  1
  ${css_contents}  Get File  ${CSS_FILE}
  ${css_ids}  Get Regexp Matches  ${css_contents}  .*?#(.*?)\\s*?\\{  1
  ${css_classes}  Get Regexp Matches  ${css_contents}  [^a-z]\\.(.*?)[\\s|\\{]  1
  ${css_ids}  Sanitize Empty Spaces From Strings  ${css_ids}
  ${css_classes}  Sanitize Empty Spaces From Strings  ${css_classes}
  Should Contain Any  ${html_ids}  @{css_ids}
  Should Contain Any  ${html_classes}  @{css_classes}

E0-T2-6: Element position and sizing options are used
  [Documentation]  Some positioning and sizing styles have been defined with CSS.
  ...  The following declarations are searched to determine positional styling:
  ...  margin, padding, position, top, right, left, bottom, align.
  ...  The following declarations are searched to determine size styling:
  ...  height, width, font-size.
  [Tags]  ex0  e0t2  full

  @{position_support_words}  Create List  margin  padding  position  align  top  right  left  bottom
  @{size_support_words}  Create List  height  width  size
  ${css_contents}  Get File  ${CSS_FILE}
  ${found_styles}  Get Regexp Matches  ${css_contents}  margin\\s*?:|margin-[a-zA-Z].*:|padding\\s*?:|padding-[a-zA-Z].*?:|position\\s*?:|[a-zA-Z].*?-align\\s*?:|width:|.*?height:|size:
  ${styles_string}  Set Variable
  FOR  ${item}  IN  @{found_styles}
    ${new_item}  Remove String  ${item}  ${SPACE}
    ${styles_string}  Catenate  ${styles_string}  ${new_item}
  END
  Should Contain Any  ${styles_string}  @{position_support_words}
  Should Contain Any  ${styles_string}  @{size_support_words}

*** Keywords ***
Initiate Static Testing
  Log  ${TEST_SUBJECT_DIR}
  ${html_file}  Search Local HTML Main Page Location  ${TEST_SUBJECT_DIR}${/}
  Should Not Be Empty  ${html_file}
  Set Global Variable  ${HTML_FILE}  ${html_file}
  ${css_files}  Search File With Extension  ${TEST_SUBJECT_DIR}  css
  ${css_file}  Get File With Most Lines  ${css_files}
  Should Not Be Empty  ${css_file}
  Set Global Variable  ${CSS_FILE}  ${css_file}

Sanitize Empty Spaces From Strings
  [Arguments]  ${strings}
  @{new_list}  Create List
  FOR  ${string}  IN  @{strings}
    ${stripped}  Strip String  ${string}
    Append To List  ${new_list}  ${stripped}
  END
  [Return]  ${new_list}

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

Verify List Element Hierarchy
  [Arguments]  ${list_elements}
  @{elements}  Split String  ${list_elements}  ${SPACE}
  &{relations}  Parent Child Relations From List  ${elements}
  FOR  ${list}  IN  @{elements}
    ${verification_result}  Verify List Item Found  ${relations}
  END
  [Return]  ${verification_result}

Verify List Item Found
  [Arguments]  ${parent_child_dict}
  ${result}  Set Variable  False
  FOR  ${relations}  IN  &{parent_child_dict}
    IF  ('${relations}[0]' == '<ul>' or '${relations}[0]' == '<ol>' or '${relations}[0]' == '<menu>')
      FOR  ${item}  IN  @{relations}[1]
        ${result}  Run Keyword And Return Status
        ...  Should Contain Any  ${item}  <li>  <script>  <template>
        IF  '${result}' == 'True'
          BREAK
        END
      END
    END
  END
  [Return]  ${result}

Check If URL Contains Path
  [Arguments]  ${src}
  ${img_contains_path}  Get Regexp Matches  ${src}  \\.\\/|[a-z0-9]\\/[a-z0-9]
  [Return]  ${img_contains_path}

Store Id References
  [Arguments]  ${elements}
  ${ids}  Create List
  FOR  ${elem}  IN  @{elements}
    @{elem_items}  Create List  ${elem.get('id')}
    FOR  ${item}  IN  @{elem_items}
      IF  '${item}' != 'None'
        Append To List  ${ids}  ${item}
      END
    END
  END
  [Return]  ${ids}

Store Class References
  [Arguments]  ${elements}
  ${classes}  Create List
  FOR  ${elem}  IN  @{elements}
    @{elem_items}  Create List  ${elem.get('class')}
    FOR  ${item}  IN  @{elem_items}
      IF  ${item} != None
        Append To List  ${classes}  @{item}
      END
    END
  END
  [Return]  ${classes}

Verify Defined Table Styles
  [Arguments]  ${css_file_contents}  ${table_ids}  ${table_classes}
  ${table_styles_found}  Get Regexp Matches  ${css_file_contents}  table.*?\\{([^}]+)\\}|td.*?\\{([^}]+)\\}|th.*?\\{([^}]+)\\}
  IF  not ${table_styles_found}
    ${table_styles_found}  Run Keyword And Return Status
    ...  Should Contain Any  ${css_file_contents}  @{table_ids}
    IF  not ${table_styles_found}
      ${table_styles_found}  Run Keyword And Return Status
      ...  Should Contain Any  ${css_file_contents}  @{table_classes}
    END
  END
  [Return]  ${table_styles_found}

Verify Defined List Styles
  [Arguments]  ${css_file_contents}  ${list_ids}  ${list_classes}
  ${list_styles_found}  Get Regexp Matches  ${css_file_contents}  ul\\s*?\\{([^}]+)\\}|ol\\s*?\\{([^}]+)\\}|menu\\s*?\\{([^}]+)\\}|li\\s*?\\{([^}]+)\\}
  IF  not ${list_styles_found}
    ${list_styles_found}  Run Keyword And Return Status
    ...  Should Contain Any  ${css_file_contents}  @{list_ids}
    IF  not ${list_styles_found}
      ${list_styles_found}  Run Keyword And Return Status
      ...  Should Contain Any  ${css_file_contents}  @{list_classes}
    END
  END
  [Return]  ${list_styles_found}

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

Verify List Elements
  [Arguments]  ${list_elements}
  ${number_of_verified_proper_list}  Set Variable  ${0}
  FOR  ${list}  IN  @{list_elements}
    ${verification_result}  Verify List Element Hierarchy  ${list}
    IF  ${verification_result}
      ${number_of_verified_proper_list}  Evaluate  ${number_of_verified_proper_list} + 1
    END
  END
  [Return]  ${number_of_verified_proper_list}