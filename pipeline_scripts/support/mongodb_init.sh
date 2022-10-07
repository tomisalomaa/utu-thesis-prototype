#!/bin/bash
cp $RESOURCES_DIR/mongod.conf /etc/mongod.conf
mongod --config /etc/mongod.conf &
HOST="localhost 27017"
WAITTIME=1
PING=true
req_num=0
while [[ $PING == true && $req_num < 10 ]]
do
    ((req_num=req_num+1))
    nc -vz ${HOST}
    if [ $? -ne 0 ]
    then
        sleep $WAITTIME
    else
        PING=false
    fi
done
mongosh < $SUPPORT_SCRIPT_DIR/mongo.js