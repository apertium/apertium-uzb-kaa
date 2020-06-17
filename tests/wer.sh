#! /bin/sh

# apertium-quality


cat texts/story.uzb.txt | apertium -d . uzb-kaa > texts/story.uzb-kaa.txt 

cat texts/story.kaa.txt | apertium -d . kaa-uzb > texts/story.kaa-uzb.txt 

echo 'WER uzb-kaa:'
perl ../../apertium-eval-translator/apertium-eval-translator-line.pl -test texts/story.uzb-kaa.txt -ref texts/story.kaa.txt > texts/uzb-kaa-wer.txt
grep '(WER)' texts/uzb-kaa-wer.txt

echo 'WER kaa-uzb:'
perl ../../apertium-eval-translator/apertium-eval-translator-line.pl -test texts/story.kaa-uzb.txt -ref texts/story.uzb.txt > texts/kaa-uzb-wer.txt
grep '(WER)' texts/kaa-uzb-wer.txt

