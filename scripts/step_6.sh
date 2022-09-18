#!/bin/bash
echo Executing dynamic tests
echo -----------------------
summaryRowPos=$FIRST_ID_POSITION
export REACT_PROJ_DIR
export REACT_BASE_DIR
export RESOURCES_DIR
for sut in $SUBJECTS_DIR/* ; do
    export sut
    export summaryRowPos
    if [ "$ASSESSMENT_EX" == "ex0" ]
    then
        ./scripts/step_6_ex0_support.sh
    elif [ "$ASSESSMENT_EX" == "ex1" ]
    then
        export et=e1t1
        ./scripts/step_6_ex1_support.sh
        export et=e1t2
        ./scripts/step_6_ex1_support.sh
    elif [ "$ASSESSMENT_EX" == "ex2" ]
    then
        export et=e2t1
        ./scripts/step_6_ex2_support.sh
        export et=e2t2
        ./scripts/step_6_ex2_support.sh
    elif [ "$ASSESSMENT_EX" == "ex3" ]
    then
        export et=e3t1
        ./scripts/step_6_ex3_support.sh
    fi
    ((summaryRowPos=summaryRowPos+1))
done
if [ "$ASSESSMENT_EX" != "ex0" ]
then
    # Kill node
    echo Killing node processes...
    pkill -f node
    echo Done!
fi
exit 0