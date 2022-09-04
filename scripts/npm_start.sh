#!/bin/bash
if [ ! -d "$1" ]
then
    echo "$1" directory missing.
    echo Creating react app...
    cd $2
    create-react-app system-under-test
    cp "$DIR/resources/.env" "$1"
else
    pkill -f node
    cp "$DIR/resources/.env" "$1"
fi
echo Executing npm CI and START
cd "$1"
npm ci
npm start &