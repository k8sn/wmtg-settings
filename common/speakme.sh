#!/bin/bash

#Text to speech writer

rm -rf /tmp/speakmeout.*
rm -rf /tmp/speakmein.*

cd /tmp

echo $1 > /tmp/speakmein.txt

testvar=$(cat speakmein.txt)
 
if [ -z "$testvar" ]; then
    exit 0
 fi

cat /tmp/speakmein.txt
/usr/local/bin/wmtg_txt2spch01.sh /tmp/speakmein.txt
/usr/bin/sox -c 2 -r 8000 -v .75 /tmp/speakmein.ul /tmp/speakmeout.ul

/usr/sbin/asterisk -rx "rpt localplay 560 /tmp/speakmeout"

cp /tmp/speakmeout.ul $2.ul



exit 0
