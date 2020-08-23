#!/bin/bash

# A script to run the standard (=full) testvoc.
#
# Assumes the pair is compiled.
# Expands the source language dictionary/transducer MONODIX and passes the
# result of the expansion through the translator (=inconsistency.sh script).
# Produces 'testvoc-summary' files using the inconsistency-summary.sh.
#
# Usage: [TMPDIR=/path/to/tmpdir] ./testvoc.sh

if [ -z $TMPDIR ]; then
	TMPDIR="/tmp"
fi

export TMPDIR

# Testvoc will finish in a reasonable time if we comment out the line
# with numerals regex in bidix:
cd ../../
sed -i 's_<e> *<re>\[№.*$_<!--&-->_' apertium-uzb-kaa.uzb-kaa.dix
make
cd testvoc/standard/

function expand_monodix {
    hfst-fst2strings -c1 $MONODIX | sort -u | cut -d':' -f2 | \
    sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g'
}

#-------------------------------------------------------------------------------
# Uzbek->Karakalpak testvoc
#-------------------------------------------------------------------------------

MONODIX=../../.deps/uzb-kaa.automorf.trimmed

echo "==Uzbek->Karakalpak==========================="

expand_monodix |
bash inconsistency.sh uzb-kaa > $TMPDIR/uzb-kaa.testvoc
bash inconsistency-summary.sh $TMPDIR/uzb-kaa.testvoc uzb-kaa
