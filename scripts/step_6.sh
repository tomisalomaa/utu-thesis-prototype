#!/bin/bash
echo Executing dynamic tests
echo -----------------------
summaryRowPos=$FIRST_ID_POSITION
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