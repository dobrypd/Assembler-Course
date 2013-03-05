#!/bin/bash

# Author Piotr Dobrowolski
# pd291528@students.mimuw.edu.pl

echo "Run only using make (in root directory)."

# FLAG, if you dont want program outputs
DELETE_OUTPUTS=0
# FLAG, if want gol to show debug informations
DEBUG_OUT=0


PROJECT_DIR=`pwd`
TESTS_IN_DIR=$PROJECT_DIR/tests/
BIN=$PROJECT_DIR/bin/
GOL=gol


for i in `find  $TESTS_IN_DIR -iname "*.input"`
do
    echo -en "\033[38m\033[32mGame Of Life runned on file : \033[0m"$i"\n"
    
    BN=$(basename $i)
    DN=$(dirname $i)
    
    GEN_OUT="${i%.*}".gen_output
    OUT_FN="${i%.*}".output
    
    if [ $DEBUG_OUT == 0 ]
    then
    	$GOL $i 1>$GEN_OUT 2> /dev/null
    else
        $GOL $i 1>$GEN_OUT.out 
    fi
    
    if [ ! -f $GEN_OUT ] || [ ! -f $OUT_FN ]
    then
        echo -en "\033[38m\033[31mBAD (output file not found) [$BN]\033[0m\n"
    else
        if diff $GEN_OUT $OUT_FN
        then
            echo -en "\033[38m\033[32mOK [$BN]\033[0m\n"
        else
            echo -en "\033[38m\033[31mBAD (outputs differs) [$BN]\033[0m\n"
        fi
    fi

done


#delete program outputs
if [ $DELETE_OUTPUTS == 1 ]
then
    find $TESTS_IN_DIR -iname "*.gen_output" | xargs rm
fi
