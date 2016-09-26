#!/bin/bash
# variables
TMPDIR=/tmp/tts
PID=$$
TMPFILE1=/tmp/tts/tmpfile1${PID}
TMPFILE2=/tmp/tts/tmpfile2${PID}
TTS_LOCK=$TMPDIR/lock_tts
VOL=6

old_IFS=$IFS
IFS=$'\n'

# setup lock file
readonly PROGNAME=$(basename "$0")
readonly LOCKFILE_DIR=$TMPDIR
readonly LOCK_FD=200

## Functions Start

lock() {
    local prefix=$1
    local fd=${2:-$LOCK_FD}
    local lock_file=$LOCKFILE_DIR/$prefix.lock

    # create lock file
    eval "exec $fd>$lock_file"

    # aquire the lock
    flock -n $fd \
        && return 0 \
       || return 1
}

help() {
    echo 
    echo "$PROGNAME <text_file_to_convert>"
    echo "Creates an ulaw audio using the text file specified."
    echo "    For example:"
    echo "    tts_audio.sh /tmp/hello.txt"
    echo
    echo "This will create a file called /tmp/hello.ul"
    echo
}

main() {

    #if lock is present, wait until lock is removed. Should only have
    # one instance of this program running.
    
    until lock $PROGNAME ; do
        sleep 20
    done

    # Each text line should be less then xx characters.  Approach is to
    # split on periods. If any further splitting, it may cause a pause in the
    # text speed due the the pause of each line.

    # first split the file using "period".
    sed 's/\. /\.\n/g' $FILE > $TMPFILE1

    ## shorten to 99 characters per line
    fold -w 99 -s $TMPFILE1 > $TMPFILE2 

    # convert text file to an mp3 file
    line=($(cat $TMPFILE2)) # array

    ## need to determine the number of lines in the file.
    LINES_IN_FILE=`wc -l $TMPFILE2 | awk '{print $1}'`

    for i in `seq 0 $LINES_IN_FILE`
    do
        # /usr/local/bin/google_tts.py "${line[$i]}" # may be helpful for debug

        line_count=`echo ${line[$i]} | wc -c`
        # check to make sure that string is less then 100, if not abort.
        if [ "$line_count" -gt "100" ] ; then
               echo "Error, string count is greater than 100 characters.  Use the -s option" 2>&1
               echo "to split lines or shorten the text lines in the file. Aborting..." 2>&1
               exit 1
        fi

        /usr/local/bin/wmtg_hub_tts.py "${line[$i]}" > /dev/null 2>&1
        if [ ! -f ${TMPDIR}/tts.wav ] ; then
             echo "ERROR, google_tts.py module failed to create mp3 file." 2>&1
             exit 1
        fi
        cp ${TMPDIR}/tts.wav ${TMPDIR}/tts_${i}.wav
    done

    # now cat all the mp3 files to a single file

    # you need to sort for the proper order tts_1, tts_2 .. tts_10
    # cat `ls  ${TMPDIR}/tts_*.wav | sort --version-sort` > ${TMPDIR}/audio.wav
    sox $(ls ${TMPDIR}/tts_*.wav | sort --version-sort) ${TMPDIR}/audio.wav &>/dev/null
    # sox $(ls /tmp/tts/tts_*.wav | sort -n -k1.5) /tmp/tts/audio.wav &>/dev/null
    
    #cd $TMPDIR
    #sox $(ls tts_*.wav | sort -n -k1.5) audio.wav
   

    sox --volume $VOL -V ${TMPDIR}/audio.wav -r 8000 -c 1 -t ul ${TMPDIR}/audio${PID}.ul &> /dev/null 2>&1
    if [ ! -f ${TMPDIR}/audio${PID}.ul ] ; then
        echo "Failed to convert wav file to u-law audio file (sox failure)"
        echo "Aborting..."
        exit 
    fi


    # clean up the temp, and wave files
    rm -f ${TMPDIR}/tts*.wav
  	rm -f ${TMPDIR}/audio.wav
    rm -f ${TMPFILE1}
    rm -f ${TMPFILE2}

    IFS=$old_IFS
    mv ${TMPDIR}/audio${PID}.ul ${FILE%.txt}.ul
}

# end of functions...

#####################################################################
# main 

# set an initial value for the flag
SPLIT=0

# read the options
TEMP=`getopt -o a::sv: --long arga::,args,argv: -n 'tts_audio.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -a|--arga)
            case "$2" in
                "") ARG_A='some default value' ; shift 2 ;;
                *) ARG_A=$2 ; shift 2 ;;
            esac ;;
        -s|--split) SPLIT=1 ; shift ;;
        -v|--vol)
            case "$2" in
                "") shift 2 ;;
                *) VOL=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

FILE=$1

VOL_ARRAY=(-0.0 -0.05 -0.1 -0.2 -0.3 -0.4 -0.5 -0.6 -0.7 -0.8 -0.9 )
# get converted volume
VOLCONV=${VOL_ARRAY[$VOL]}

if [ "$VOLCONV" = "" ] ; then
    echo "Error in setting the volume. The argument must be an integer value from"
    echo " 1 through 10,  aborting"
    exit 1
fi

VOL=$VOLCONV

# make sure that the temp directory is there
if [ ! -d $TMPDIR ] ; then
    mkdir -p $TMPDIR
fi

if [ $# -eq 0 ] ; then
    echo "No arguments supplied"
    help
    exit 1
fi

# call main funciton.
main

exit 0

