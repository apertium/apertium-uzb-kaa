#!/bin/bash

# This script takes the output of the inconsistency.sh script and prints some
# stats about it.
# It is supposed to be invoked by ./testvoc.sh, and not run directly.

INC="$1"
OUT="testvoc-summary.$2.txt"
POS="n adj v vaux adv cm cnjcoo det guio ij np num post prn cnjsub"

ECHOE="echo -e"
SED=sed

if test x$(uname -s) = xDarwin; then
        ECHOE="builtin echo"
        SED=gsed
fi


echo "" > "$OUT";

date >> "$OUT"
$ECHOE  "===============================================" >> "$OUT"
$ECHOE  "POS\tTotal\tClean\tWith @\tWith #\tClean %" >> "$OUT"

aterrors=$(mktemp -t testvoc.XXXXXXXXXX)
hasherrors=$(mktemp -t testvoc.XXXXXXXXXX)

<"$INC" sed 's/~#/#/g' | grep -v -e '->  *#'   -e REGEX | grep -e '->  *\^@' > "$aterrors"
<"$INC" sed 's/~#/#/g' | grep -v -e '->  *\^@' -e REGEX | grep -e '>  *#'    > "$hasherrors"


for i in $POS; do
	if [ "$i" = "det" ]; then
		remove-other-pos () { grep -v -e '<n>' -e '<np>' -e '<adj>' -e '<num>'; }
	elif [ "$i" = "preadv" ]; then
		remove-other-pos () { grep -v -e '<adj>' -e '<adv>'; }
	elif [ "$i" = "adj" ]; then
		remove-other-pos () { grep -v -e '<part>' -e '<qst>' -e '<cnj' -e '<v' ; }
	elif [ "$i" = "adv" ]; then
		remove-other-pos () { grep -v -e '<part>' -e '<qst>' -e '<cnj' -e '<v' -e '<adj>'; }
	elif [ "$i" = "cnjcoo" ]; then
		remove-other-pos () { grep -v -e '<v>' -e '<n>' -e '<adj>'; }
	elif [ "$i" = "np" ]; then
		remove-other-pos () { grep -v -e '<part>' -e '<qst>' -e '<cnj'; }
	elif [ "$i" = "n" ]; then
		remove-other-pos () { grep -v -e '<part>' -e '<qst>' -e '<cnj'; }
	elif [ "$i" = "v" ]; then
		remove-other-pos () { grep -v -e '<part>' -e '<qst>' -e '<cnj'; }
	elif [ "$i" = "pr" ]; then
		remove-other-pos () { grep -v -e '<vblex>' -e '<vaux>' -e '<n>' -e '<adv>' -e '<adj>' -e '<num>'; }
	elif [ "$i" = "prn" ]; then
		remove-other-pos () { grep -v -e '<vblex>' -e '<vaux>' -e '<n>'; }
	else
		remove-other-pos () { cat; }
	fi
	TOTAL=$(grep -v REGEX "$INC" | remove-other-pos | grep "<$i>" -c )
	AT=$(<"$aterrors" remove-other-pos | grep -c "<$i>" )
	HASH=$(<"$hasherrors" remove-other-pos |  grep -c "<$i>" )

	UNCLEAN=$(calc -p "$AT+$HASH")
	CLEAN=$(calc -p "$TOTAL-$UNCLEAN")
	PERCLEAN=$(calc -p "$UNCLEAN/$TOTAL*100" | sed 's/~//g' | head -c 5)
	echo $PERCLEAN | grep "Err" > /dev/null;
	if [ $? -eq 0 ]; then
		TOTPERCLEAN="100";
	else
		TOTPERCLEAN=$(calc -p "100-$PERCLEAN" | sed 's/~//g' | head -c 5)
	fi

	$ECHOE "$TOTAL;$i;$CLEAN;$AT;$HASH;$TOTPERCLEAN"
done | sort -gr | awk -F';' '{print $2"\t"$1"\t"$3"\t"$4"\t"$5"\t"$6}' >> "$OUT"

#rm -f "$aterrors" "$hasherrors"

$ECHOE "===============================================" >> "$OUT"
cat "$OUT"
