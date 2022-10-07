#!/bin/bash
echo Executing npm install and run
cd "$1"
npm install
npm run watch &