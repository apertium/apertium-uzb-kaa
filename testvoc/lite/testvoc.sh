#!/bin/bash

# A script to run the "lite" ("one-word-per-each-paradigm-") testvoc.
#
# Assumes the pair is compiled.
# Extracts lexical units from compressed text files in languages/apertium-uzb/
# tests/morphotactics/ and languages/apertium-kaa/tests/morphotactics
# and passes them through the translator (=INCONSISTENCY script).
# Produces 'testvoc-summary' files using the INCONSISTENCY_SUMMARY script.
#
# TODO: Generate stats about each file (e.g. N1.txt), not just about the category (e.g. nouns).
#
# Usage: [TMPDIR=/path/to/tmpdir] ./testvoc.sh

INCONSISTENCY=../standard/./inconsistency.sh
INCONSISTENCY_SUMMARY=../standard/./inconsistency-summary.sh

if [ -z $TMPDIR ]; then
	TMPDIR="/tmp"
fi

export TMPDIR

function extract_lexical_units {
    sort -u | cut -f2 -d':' | \
    sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g'
}

#-------------------------------------------------------------------------------
# Uzbek->Karakalpak testvoc
#-------------------------------------------------------------------------------

PARDEF_FILES=../../../../languages/apertium-uzb/tests/morphotactics/*.txt.gz

echo "==Uzbek->Karakalpak==========================="

echo "" > $TMPDIR/uzb-kaa.testvoc

for file in $PARDEF_FILES; do
    zcat $file | extract_lexical_units |
    $INCONSISTENCY uzb-kaa >> $TMPDIR/uzb-kaa.testvoc
done

$INCONSISTENCY_SUMMARY $TMPDIR/uzb-kaa.testvoc uzb-kaa

#-------------------------------------------------------------------------------
# Karakalpak->Uzbek testvoc
#-------------------------------------------------------------------------------

# TODO
