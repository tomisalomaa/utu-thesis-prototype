*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         ${LIBRARIES_DIR}${/}MyLibrary.py
Variables       ${GLOBAL_ROBO_VARIABLES_DIR}${/}common_variables.py
Resource        ${RESOURCES_DIR}${/}common_keywords.resource
Suite Setup     Initiate Static Testing

*** Test Cases ***