#!/bin/bash
if [ "$ASSESSMENT_EX" == "ex0" ] || [ "$ASSESSMENT_EX" == "ex1" ] || [ "$ASSESSMENT_EX" == "ex2" ] || [ "$ASSESSMENT_EX" == "ex3" ]
then
    echo Verifying directory structure
    echo ------------------------------

    # Check pipeline scripts
    if [ -d "$SCRIPT_DIR" ]
    then
        if ! [ -f "$MAIN_SCRIPT_DIR/step_1.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_1.sh missing, ending pipeline execution!
            exit 1
        fi
        if ! [ -f "$MAIN_SCRIPT_DIR/step_2.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_2.sh missing, ending pipeline execution!
            exit 1
        fi
        if ! [ -f "$MAIN_SCRIPT_DIR/step_3.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_3.sh missing, ending pipeline execution!
            exit 1
        fi
        if ! [ -f "$MAIN_SCRIPT_DIR/step_4.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_4.sh missing, ending pipeline execution!
            exit 1
        fi
        if ! [ -f "$MAIN_SCRIPT_DIR/step_5.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_5.sh missing, ending pipeline execution!
            exit 1
        fi
        if ! [ -f "$MAIN_SCRIPT_DIR/step_6.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_6.sh missing, ending pipeline execution!
            exit 1
        fi
        if ! [ -f "$MAIN_SCRIPT_DIR/step_7.sh" ]
        then
            echo $MAIN_SCRIPT_DIR/step_7.sh missing, ending pipeline execution!
            exit 1
        else
            echo $SCRIPT_DIR/scripts OK.
        fi
    fi

    # Check input data
    if [ -d "$DIR/data/submissions/$ASSESSMENT_EX" ]
    then
        echo $DIR/data/submissions/$ASSESSMENT_EX OK.
    else
        echo $DIR/data/submissions/$ASSESSMENT_EX not found.
        echo No submission content available, ending pipeline execution!
        exit 1
    fi

    if [ -d "$DIR/data/test-subjects" ]
    then
        rm -r $DIR/data/test-subjects/*
        echo $DIR/data/test-subjects OK.
    else
        echo $DIR/data/test-subjects missing..
        echo "    Making directory.."
        mkdir -p $DIR/data/test-subjects/
        if [ -d "$DIR/data/test-subjects" ]
        then
            echo "    $DIR/data/test-subjects OK."
        else
            echo "    Could not make directory $DIR/data/test-subjects"
            exit 1
        fi
    fi

    # Check tests and tasks directories and files
    if [ -d "$DIR/robot_scripts/tests" ]
    then
        echo "$DIR/robot_scripts/test OK."
    else
        echo "Missing $DIR/robot_scripts/tests!"
        exit 1
    fi

    if [ -d "$DIR/robot_scripts/tasks" ]
    then
        echo "$DIR/robot_scripts/tasks OK."
    else
        echo "Missing $DIR/robot_scripts/tasks!"
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
    if [ -d "$DIR/results/"$ASSESSMENT_EX"" ]
    then
        echo "$DIR/results/"$ASSESSMENT_EX" OK."
    else
        echo $DIR/results/"$ASSESSMENT_EX" missing..
        echo "    Making directory.."
        mkdir -p $DIR/results/"$ASSESSMENT_EX"/
        if [ -d "$DIR/results/"$ASSESSMENT_EX"" ]
        then
            echo "    $DIR/results/"$ASSESSMENT_EX" OK."
        else
            echo "    Could not make directory $DIR/results/"$ASSESSMENT_EX"/"
            exit 1
        fi
    fi

    if [ -d "$DIR/reports/"$ASSESSMENT_EX"" ]
    then
        echo "$DIR/reports/"$ASSESSMENT_EX" OK."
    else
        echo $DIR/reports missing..
        echo "    Making directory.."
        mkdir -p $DIR/reports/"$ASSESSMENT_EX"/
        if [ -d "$DIR/reports/"$ASSESSMENT_EX"" ]
        then
            echo "    $DIR/reports/"$ASSESSMENT_EX" OK."
        else
            echo "    Could not make directory $DIR/reports/"$ASSESSMENT_EX"/"
            exit 1
        fi
    fi

    # If ex3, perform mongodb related directory checks
    # (consider saving directories in variables)
    if [ "$ASSESSMENT_EX" == "ex3" ]
    then
        if [ -d "/home/data/db" ]
        then
            echo "    /home/data/db OK."
        else
            echo /home/data/db missing..
            echo "    Making directory.."
            mkdir -p /home/data/db
            if [ -d "/home/data/db" ]
            then
                echo "    /home/data/db OK."
            else
                echo "    Could not make directory /home/data/db"
                exit 1
            fi
        fi
        if [ -d "/home/data/log/mongodb" ]
        then
            echo "    /home/data/log/mongodb OK."
        else
            echo /home/data/log/mongodb missing..
            echo "    Making directory.."
            mkdir -p /home/data/log/mongodb
            if [ -d "/home/data/log/mongodb" ]
            then
                echo "    /home/data/log/mongodb OK."
            else
                echo "    Could not make directory /home/data/log/mongodb"
                exit 1
            fi
        fi
    fi

    # End script execution
    echo All files and folders successfully verified!
    echo Starting pipeline to assess "$ASSESSMENT_EX" exercises...
    exit 0
else
    echo Improper argument given: "$ASSESSMENT_EX".
    echo Specify either \"ex0\", \"ex1\", \"ex2\" or \"ex3\" to determine the scope of assessment.
    exit 1
fi