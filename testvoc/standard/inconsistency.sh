#!/bin/bash

# Passes its input -- a list of lexical units -- through the translator
# (transfer modules and target language generator).
# Creates three text files in TMPDIR:
#     1) INPUT, a list of lexical units taken
#     2) TRANSFOUT, this list after passing transfer modules
#     3) GENOUT, this list after TL generator.
# Outputs "paste INPUT TRANSFOUT GENOUT"
# Supposed to be invoked by ./testvoc.sh, and not run directly.

if [ -z $TMPDIR ]; then
	TMPDIR="/tmp"
fi

INPUT=$TMPDIR/testvoc_input.txt
TRANSFOUT=$TMPDIR/testvoc_transfout.txt
GENOUT=$TMPDIR/testvoc_genout.txt

DIR=$1

if [[ $DIR = "uzb-kaa" ]]; then

    PRETRANSFER="apertium-pretransfer"
    LEXTRANSFER="lt-proc -b ../../uzb-kaa.autobil.bin"
    LEXSELECTION="lrx-proc -m ../../uzb-kaa.autolex.bin"
    TRANSFER="rtx-proc ../../uzb-kaa.rtx.bin"
    #TRANSFER_1="apertium-transfer -b ../../apertium-uzb-kaa.uzb-kaa.t1x ../../uzb-kaa.rtx.bin"
    #TRANSFER_2="apertium-transfer -n ../../apertium-uzb-kaa.uzb-kaa.t2x ../../uzb-kaa.rlx.bin"
    GENERATOR="lt-proc -d ../../uzb-kaa.autogen.bin"

    tee $INPUT |
    $PRETRANSFER | $LEXTRANSFER | $LEXSELECTION |
    $TRANSFER | tee $TRANSFOUT |
    $GENERATOR > $GENOUT
    paste -d % $INPUT $TRANSFOUT $GENOUT |
    sed 's/\^.<sent>\$//g' | sed 's/%/   -->  /g'

else
	echo "Usage: ./inconsistency.sh <direction>";
fi
