# Robot Framework Base Project
Empty base project for a new Robot Framework project

## LIST OF BEST PRACTICES
1. [Folder structure](#folder-structure)
2. [General Practices](#general-practices)
    * [Use variables](#use-variables)
    * [Use tags](#use-tags)
    * [Detailed logging](#detailed-logging)
3. [Browser Practices](#best-practices)
    * [Web element locator strategies](#web-element-locator-strategies)
    * [Headless mode](#headless-mode)
    * [Teardown screenshot](#teardown-screenshot)
    * [Custom browser capabilities](#custom-browser-capabilities)
    
## FOLDER STRUCTURE
rf-base-project:
- libraries
    * **.py** keyword libraries (e.g. 'LoginLibrary.py')
- resources
    * **.resource** keyword files (e.g. 'login_keywords.resource')
- tests
    * **.robot** test suites (e.g. 'login_tests.robot')
- variables
    * **.resource** variable files (e.g. 'login_variables.resource')

Run tests inside folder **~/rf-base-project/**
```robotframework
robot -d results tests/tests.robot
```

## GENERAL PRACTICES

### Use variables
```robotframework
# For local variables use lowercase
${username}  Tapio
${address}   Tapiolankatu 12

# For constants use uppercase
${BROWSER}  chrome
${ENVIRONMENT}   local

# For locators create hierarchy with naming
${LOC_HOME_NAV_LOGIN}  id:login
${LOC_HOME_NAV_REGISTER}  id:register
${LOC_HOME_FOOTER_PRIVACY_POLICY}  id:privacy-policy
${LOC_HOME_FOOTER_CONTACT}  id:contact

# Combine variables during execution:
# robot -results -v $BROWSER:firefox -v $ENVIRONMENT:aws tests
```
### Use tags
```robotframework
*** Test Cases ***
Homepage login test
  [Tags]  homepage login
  Log  Homepage login
  
Homepage signup test
  [Tags]  homepage signup
  Log  Homepage signup
  
# Use tags to include(-i) / exclude(-e) only wanted tests:
# robot -d results -i homepage tests
# robot -d results -e login tests
```

### Detailed logging
```robotframework
# To get the python execution trace (for more detailed debugging) printed on the log,
# run the test with flag '-L trace':  
# robot -d results -L trace tests
```

## BROWSER PRACTICES

### Web element locator strategies
```robotframework
# Web elements, like buttons, are accessed by their XPATH locator (e.g. "//button[@id='login-button']").
# 'id' is the best and first locator to use, as it presumably changes the least often:
# ${LOC_LOGIN_BUTTON}    id:login-button
# If 'id' attribute is not available, try one of the following attributes:
# 'name', 'class', 'identifier', 'link'
# If the attributes are not available, try building XPATH expression:
# ${LOC_LOGIN_BUTTON}    xpath://element[@attribute='value']
# For searching elements that contain some text:
# ${LOC_LOGIN_BUTTON}    xpath://element[contains(text(), 'the element's text')]
```

### Headless mode
```robotframework
# Running browser 'headless' means no browser windows are drawn, saving processsing time and making tests run faster
# In the newest versions of SeleniumLibrary, you can simply set the browser to 'headlesschrome' instead of 'chrome'
# Also available: 'headlessfirefox'
Open Browser    http://www.sogeti.com    headlesschrome
```

### Teardown screenshot
```robotframework
# When a test fails, it would be nice to have information about the last state it was in.
# That's why it is convenient to take screenshot at test teardown.
*** Settings ***
Test Teardown  Close test

*** Keywords ***
Close test
   # Take a screenshot
   Run Keyword if Test Failed    Capture Page Screenshot
   # Do other teardown stuff
   Log  Test teardown in progress...
```

### Custom browser capabilities
```robotframework
# Example keyword for running chrome with different capabilities
Headless Chrome - Open Browser
    [Arguments]    ${url}
    # Add new variable chrome options
    ${chrome_options} =     Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    # To run chrome in headless mode, add:
    Call Method    ${chrome_options}   add_argument    headless
    # To run chrome without gpu, add:
    Call Method    ${chrome_options}   add_argument    disable-gpu
    # Add these to options
    ${options}=     Call Method     ${chrome_options}    to_capabilities
    # Open browser with options
    Open Browser    ${url}    browser=chrome    desired_capabilities=${options}
    # Maximize
    Maximize Browser Window
```


...More to come!
