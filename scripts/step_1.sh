#!/bin/bash
echo Verifying directory structure
echo ------------------------------

# Check pipeline scripts

if [ -d "$SCRIPT_DIR" ]
then
    if ! [ -f "$SCRIPT_DIR/step_1.sh" ]
    then
        echo $SCRIPT_DIR/step_1.sh missing, ending pipeline execution!
        exit 1
    fi
    if ! [ -f "$SCRIPT_DIR/step_2.sh" ]
    then
        echo $SCRIPT_DIR/step_2.sh missing, ending pipeline execution!
        exit 1
    fi
    if ! [ -f "$SCRIPT_DIR/step_3.sh" ]
    then
        echo $SCRIPT_DIR/step_3.sh missing, ending pipeline execution!
        exit 1
    fi
    if ! [ -f "$SCRIPT_DIR/step_4.sh" ]
    then
        echo $SCRIPT_DIR/step_4.sh missing, ending pipeline execution!
        exit 1
    fi
    if ! [ -f "$SCRIPT_DIR/step_5.sh" ]
    then
        echo $SCRIPT_DIR/step_5.sh missing, ending pipeline execution!
        exit 1
    fi
    if ! [ -f "$SCRIPT_DIR/step_6.sh" ]
    then
        echo $SCRIPT_DIR/step_6.sh missing, ending pipeline execution!
        exit 1
    fi
    if ! [ -f "$SCRIPT_DIR/step_7.sh" ]
    then
        echo $SCRIPT_DIR/step_7.sh missing, ending pipeline execution!
        exit 1
    else
        echo $DIR/scripts OK.
    fi
fi

# Check input data

if [ -d "$DIR/data/submissions" ]
then
    echo $DIR/data/submissions OK.
else
    echo $DIR/data/submissions not found.
    echo No submission content available, ending pipeline execution!
    exit 1
fi

if [ -d "$DIR/data/test-subjects" ]
then
    echo $DIR/data/test-subjects OK.
else
    echo $DIR/data/test-subjects missing..
    echo "    Making directory.."
    mkdir $DIR/data/test-subjects
    if [ -d "$DIR/data/test-subjects" ]
    then
        echo "    $DIR/data/test-subjects OK."
    else
        echo "    Could not make directory $DIR/data/test-subjects"
        exit 1
    fi
fi

# Check tests and tasks directories and files
if [ -d "$DIR/tests" ]
then
    echo "$DIR/tests OK."
else
    echo "Missing $DIR/tests!"
    exit 1
fi

if [ -d "$DIR/tasks" ]
then
    echo "$DIR/tasks OK."
else
    echo "Missing $DIR/tests!"
    exit 1
fi

# Check custom libraries, common keyword files and global variables file

if [ -d "$DIR/libraries" ]
then
    if [ -f "$DIR/libraries/MyLibrary.py" ]
    then
        echo "$DIR/libraries OK."
    else
        echo "Missing $DIR/libraries/MyLibrary.py!"
        exit 1
    fi
else
    echo "Missing $DIR/libraries!"
    exit 1
fi

if [ -d "$DIR/resources" ]
then
    if [ -f "$DIR/resources/common_keywords.resource" ]
    then
        echo "$DIR/resources OK."
    else
        echo "Missing $DIR/resources/common_keywords!"
        exit 1
    fi
else
    echo "Missing $DIR/resources!"
    exit 1
fi

if [ -d "$DIR/variables" ]
then
    if [ -f "$DIR/variables/common_variables.py" ]
    then
        echo "$DIR/variables OK."
    else
        echo "Missing $DIR/variables/common_variables.py!"
        exit 1
    fi
else
    echo "Missing $DIR/variables!"
    exit 1
fi

# Check log and artifact destination folders

if [ -d "$DIR/results" ]
then
    echo "$DIR/results OK."
else
    echo $DIR/reports missing..
    echo "    Making directory.."
    mkdir $DIR/results
    if [ -d "$DIR/results" ]
    then
        echo "    $DIR/results OK."
    else
        echo "    Could not make directory $DIR/results"
        exit 1
    fi
fi

if [ -d "$DIR/reports" ]
then
    echo "$DIR/reports OK."
else
    echo $DIR/reports missing..
    echo "    Making directory.."
    mkdir $DIR/reports
    if [ -d "$DIR/reports" ]
    then
        echo "    $DIR/reports OK."
    else
        echo "    Could not make directory $DIR/reports"
        exit 1
    fi
fi

# End script execution
echo All files and folders successfully verified!
exit 0