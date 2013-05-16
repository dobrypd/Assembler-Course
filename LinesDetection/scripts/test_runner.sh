#!/bin/bash

# Author Piotr Dobrowolski
# pd291528@students.mimuw.edu.pl

echo "Run only using make (in root directory)."

# FLAG, if you dont want program outputs
DELETE_OUTPUTS=1
# FLAG, if want gol to show debug informations
DEBUG_OUT=0


PROJECT_DIR=`pwd`
TESTS_IN_DIR=$PROJECT_DIR/tests/
BIN=$PROJECT_DIR/bin/
LINEDETECTOR_ARGS=
LINEDETECOR="$PROJECT_DIR/linedetector $LINEDETECTOR_ARGS"


#TODO: XXX: this testing script file should be change to test LineDetection instead of gol.
# This one was only copied from other project.

for i in `find  $TESTS_IN_DIR -iname "*.output"`
do  
    BN=$(basename $i)
    DN=$(dirname $i)
    
    FILENAME_WTH_ITERATIONS="${BN%.*}"
    INPUT_FILENAME_SMALL="${FILENAME_WTH_ITERATIONS%_*}"
    INPUT_FILENAME="$DN/$INPUT_FILENAME_SMALL.input"
    GEN_OUT=$DN/$FILENAME_WTH_ITERATIONS.gen_output
    OUT_FN=$DN/$FILENAME_WTH_ITERATIONS.output
    ITERATIONS="${FILENAME_WTH_ITERATIONS##*_}"
    
    echo -en "\033[38m\033[32mGame Of Life runned on file : \033[0m"$INPUT_FILENAME_SMALL"\tIterations :"
    echo -en "\033[38m\033[35m $ITERATIONS\033[0m\n"
    
    if [ $DEBUG_OUT == 0 ]
    then
    	$GOL $ITERATIONS < $INPUT_FILENAME 1>$GEN_OUT 2> /dev/null
    else
        $GOL $ITERATIONS < $INPUT_FILENAME 1>$GEN_OUT 
    fi
    
    #Remove elapsed time
	sed -i '$ d' $GEN_OUT
    
    if [ ! -f $GEN_OUT ] || [ ! -f $OUT_FN ]
    then
        echo -en "\033[38m\033[31mBAD (output file not found) [$INPUT_FILENAME_SMALL]\033[0m\n"
    else
        if diff $GEN_OUT $OUT_FN
        then
            echo -en "\033[38m\033[32mOK [$INPUT_FILENAME_SMALL]\033[0m\n"
        else
            echo -en "\033[38m\033[31mBAD (outputs differs) [$INPUT_FILENAME_SMALL]\033[0m\n"
        fi
    fi

done


#delete program outputs
if [ $DELETE_OUTPUTS == 1 ]
then
    find $TESTS_IN_DIR -iname "*.gen_output" | xargs rm
fi
