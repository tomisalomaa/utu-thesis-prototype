#!/bin/bash
pkill -f node
if [ ! -d "$1" ]
then
    echo "$1" directory missing.
    cd $2
    create-react-app system-under-test
else
   :
fi
if [ $ASSESSMENT_EX == "ex1" ]
then
    cp "$RESOURCES_DIR"/package-ex1.json "$REACT_PROJ_DIR"package.json
    cp "$RESOURCES_DIR"/package-lock-ex1.json "$REACT_PROJ_DIR"package-lock.json
    cp "$RESOURCES_DIR"/.env "$REACT_PROJ_DIR".env
elif [ $ASSESSMENT_EX == "ex3" ]
then
    cp "$RESOURCES_DIR"/package-ex3.json "$REACT_PROJ_DIR"package.json
    cp "$RESOURCES_DIR"/package-lock-ex3.json "$REACT_PROJ_DIR"package-lock.json
fi
cp "$RESOURCES_DIR"/db.json "$REACT_PROJ_DIR"db.json
cp "$RESOURCES_DIR"/.env "$REACT_PROJ_DIR".env
if [ $3 == true ]
then
    echo Executing npm install
    cd "$1"
    npm install
else
    echo Executing npm install and start
    cd "$1"
    npm install
    npm start &
fi