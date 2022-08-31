#!/bin/bash
echo Executing dynamic tests
echo -----------------------
summaryRowPos=$FIRST_ID_POSITION
for sut in $SUBJECTS_DIR/* ; do
    export sut
    export summaryRowPos
    export et=e1t1
    ./scripts/step_6_ex1_support.sh
    export et=e1t2
    ./scripts/step_6_ex1_support.sh

    ((summaryRowPos=summaryRowPos+1))

    if [ "$ASSESSMENT_EX" != "ex0" ]
    then
        # Kill node
        echo Killing node processes...
        pkill -f node
        echo Done!
    fi
done
exit 0