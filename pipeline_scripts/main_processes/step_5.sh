#!/bin/bash
echo Preparing dynamic tests
echo -----------------------
export REACT_PROJ_DIR
export REACT_BASE_DIR
if [ "$ASSESSMENT_EX" != "ex0" ]
then
    pkill -f node
    $SUPPORT_SCRIPT_DIR/npm_start.sh $REACT_PROJ_DIR $REACT_BASE_DIR true
fi
if [ "$ASSESSMENT_EX" == "ex3" ]
then
    $SUPPORT_SCRIPT_DIR/mongodb_init.sh
    $SUPPORT_SCRIPT_DIR/mongodb_start.sh
    HOST="localhost 27017"
    WAITTIME=3
    PING=true
    req_num=0
    echo "Will perform up to 20 requests while waiting for mongo to answer."
    while [[ $PING == true && $req_num < 61 ]]
    do
        ((req_num=req_num+1))
        nc -vz ${HOST}
        if [ $? -ne 0 ]
        then
            echo "Waiting for mongo to be ready (req# $req_num)..."
            sleep $WAITTIME
        else
            PING=false
        fi
    done
fi
exit 0