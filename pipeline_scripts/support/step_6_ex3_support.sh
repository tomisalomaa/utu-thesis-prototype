#!/bin/bash
# Wait for the npm to be ready
HOST="localhost 3001"
WAIT_TIME=3
PING=true
req_num=0
echo "Will perform up to 20 requests while waiting for npm start."
while [[ $PING == true && $req_num < 61 ]]
do
    ((req_num=req_num+1))
    nc -vz ${HOST}
    if [ $? -ne 0 ]
    then
        echo "Waiting for npm start to be ready (req# $req_num)..."
        sleep $WAIT_TIME
    else
        PING=false
    fi
done

# Run tests
robot \
    --name  "$(basename "$sut") dynamic tests" \
    -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/ \
    -i $et \
    -v TEST_SUBJECT_DIR:"$sut" \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v DYNA_FOLDER:"$REACT_PROJ_DIR" \
    -v REACT_APP_ADDR:"http://localhost:3000" \
    -v REACT_SERVER_ADDR:"http://localhost:3001" \
    -v LIBRARIES_DIR:"$LIBRARIES_DIR" \
    -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
    -v RESOURCES_DIR:"$RESOURCES_DIR" \
    $TESTS_DIR/"$ASSESSMENT_EX"-dynamic-tests.robot

# Update score
robot \
    --name  "Update score for $(basename "$sut")" \
    -d $RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/step_6/ \
    -i existing \
    -v STUDENT_ID:"$(basename "$sut")" \
    -v STUDENT_OUTPUT:$RESULTS_DIR/"$ASSESSMENT_EX"/"$(basename "$sut")"/dynamic/output.xml \
    -v STUDENT_REPORT_ROW:${summaryRowPos} \
    -v EX_NUM:"$ASSESSMENT_EX" \
    -v GLOBAL_ROBO_VARIABLES_DIR:"$GLOBAL_ROBO_VARIABLES_DIR" \
    -v RESOURCES_DIR:"$RESOURCES_DIR" \
    -v REPORTS_DIR:"$REPORTS_DIR" \
    $TASKS_DIR/update_score.robot

# Kill node process and empty mongo db collection
pkill -f node
mongosh --eval 'db.ex3tests.remove( { } )' &