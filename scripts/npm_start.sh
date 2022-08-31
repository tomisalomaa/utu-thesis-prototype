#!/bin/bash
if [ ! -d "$REACT_PROJ_DIR" ]
then
    echo "$REACT_PROJ_DIR" directory missing.
    echo Creating react app...
    cd "$REACT_BASE_DIR"
    create-react-app system-under-test
    cp "$DIR/resources/.env" "$REACT_PROJ_DIR"
else
    pkill -f node
    cp "$DIR/resources/.env" "$REACT_PROJ_DIR"
fi
echo Executing npm CI and START
cd "$REACT_PROJ_DIR"
npm ci
npm start &