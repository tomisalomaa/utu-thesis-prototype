#!/bin/bash
echo Preparing dynamic tests
echo -----------------------
if [ "$ASSESSMENT_EX" != "ex0" ]
then
    HOST="localhost 3000"
    WAITTIME=3
    PING=true
    req_num=0
    echo "Will perform up to 20 requests while waiting for npm start."
    while [[ $PING == true || req_num < 61 ]]
    do
        ((req_num=req_num+1))
        nc -vz ${HOST}
        if [ $? -ne 0 ]
        then
            echo "Waiting for npm start to be ready (req# $req_num)..."
            sleep $WAITTIME
        else
            PING=false
        fi
    done
else
    echo No preparations needed when assessing "$ASSESSMENT_EX"
fi
exit 0