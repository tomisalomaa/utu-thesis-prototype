*** Settings ***
Library         OperatingSystem
Library         String
Library         Collections
Library         Browser
Library         ..${/}libraries${/}MyLibrary.py
Variables       ..${/}variables${/}common_variables.py
Resource        ..${/}resources${/}common_keywords.resource
Suite Setup     Initiate Static Testing

*** Test Cases ***