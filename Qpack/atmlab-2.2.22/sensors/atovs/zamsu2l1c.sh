#!/bin/bash
# zamsu2l1c.sh: converts bzipped or gzipped amsu l1b files to l1c files.
# usage: zamsu2l1c.sh /full/path/to/bzipped/amsu/file /path/to/l1c/file
# based on stolen script from Oliver.
#
# supposed to be used from IDL. 
# example: spawn,'zamsu2l1c.sh /full/path/to/bzipped/amsu/file outputfile'
# to trace an error check where output file exist. if it does not exist
# something went wrong.

AMSUFILE=$1
L1CFILE=$2
TMPD=/tmp/zamsu2l1c$$
OLDDIR=`pwd`

HOSTOS=`uname -a|awk '{print $1}'`

case $HOSTOS in
  Linux) 
    # GNU head behaves differently than HPUX head :-(
    HEAD3="head -c 3"
    ;;
  HP-UX)
    # HPUX
    HEAD3="head -c -n 3"
    ;;
  *)
    echo "WARNING: Host OS unknown. Assuming Linux."
    HEAD3="head -c 3"
    ;;
esac

# If no absolute path is given for output file, prepend current dir
[ "$L1CFILE" ] && [ "$(echo "$L1CFILE" | sed 's/^\(.\).*$/\1/')" != "/" ] \
&& L1CFILE="$(pwd)/$L1CFILE"

#trap "cd $OLDDIR; [ -e $TMPD/atovin.log ] && cp $TMPD/atovin.log .; rm -rf $TMPD" QUIT TERM KILL EXIT
# Copying atovin.log to current doesn't make sense because it's
# overwritten by other jobs running at the same time
trap "cd $OLDDIR; rm -rf $TMPD" QUIT EXIT
trap "echo 1; echo \"Killed\"; exit 6" TERM KILL SIGINT

if [ ! $# -eq 2 -a ! $# -eq 1 ]
    then
    echo 1
    echo "Usage: $(basename $0) INFILE [OUTFILE]"
    exit 1
fi


if [ ! -r $AMSUFILE ]
    then
    echo 1
    echo "file does not exist / not readable"
    exit 1
fi

[ "$L1CFILE" ] && [ -e "$L1CFILE" ] && rm -f $L1CFILE

MKDIRERROR=no
mkdir -p $TMPD || MKDIRERROR=yes

if [ x$MKDIRERROR = xyes ]
then
    echo 1
    echo "could not mkdir"
    exit 1
fi

cd $TMPD

FORMAT=`basename $AMSUFILE | sed "s/^.*NSS\.\(....\)\..*$/\1/"`
case $FORMAT in
    AMAX) FORMAT=AMSU-A
    INFILE=aman.l1b;;
    AMBX) FORMAT=AMSU-B
    INFILE=ambn.l1b;;
    HIRX) FORMAT=HIRS
    INFILE=hrsn.l1b;;
    HIRS) FORMAT=HIRS
    INFILE=hrsn.l1b;;
    MHSX) FORMAT=AMSU-B
    INFILE=ambn.l1b;;
    *) echo "Unknown format $FORMAT"
    echo 1
    exit 1
    ;;
esac

ZIPEXT=`echo $AMSUFILE | sed "s/^.*\(...\)$/\1/"`

if [ "$ZIPEXT" = "bz2" ]; then
    UNZIP="bzip2 -cd"
elif [ "$ZIPEXT" = ".gz" ]; then
    UNZIP="gzip -cd"
else
    echo 1
    echo "could not unzip, unknown file extension"
    cd $OLDDIR
    exit 1
fi

UNZIPERROR=no
SAACUTOFF=
if [ "$($UNZIP $AMSUFILE | $HEAD3)" != "NSS" ]; then
    echo "File header doesn't start with NSS, crunching SAA header"
    SAACUTOFF="tail -c +513"
    if [ "$($UNZIP $AMSUFILE | $SAACUTOFF | $HEAD3)" != "NSS" ]; then
        echo "Still no NSS header found, bailing out"
        UNZIPERROR=yes;
    fi
fi

if [ x$UNZIPERROR = xno ]; then
    if [ "$SAACUTOFF" ]; then
        $UNZIP $AMSUFILE | $SAACUTOFF > $INFILE
    else
        $UNZIP $AMSUFILE > $INFILE
    fi
fi

if [ x$UNZIPERROR = xyes -o ! -e "$INFILE" ]
then
    echo 1
    echo "Could not unzip"
    cd $OLDDIR
    exit 1
fi

ATOV_ERROR=yes
export GFORTRAN_STDIN_UNIT=5 
export GFORTRAN_STDOUT_UNIT=6 
export GFORTRAN_STDERR_UNIT=0
# first try
atovin $FORMAT 2>&1 && ATOV_ERROR=no

if [ x$ATOV_ERROR = xyes ]           # second try
then        
    echo 1
    echo "could not convert to l1c"
    cd $OLDDIR
    exit 1
fi

MVERROR=no
if [ "$L1CFILE" ]; then
    mv `basename $INFILE l1b`l1c $L1CFILE || MVERROR=yes
else
    rm -f "`basename $INFILE l1b`l1c"
fi

if [ x$MVERROR = xyes ]
then
    echo 1
    echo "could not move $INFILE to $L1CFILE"
    exit 1
fi


# everything went ok.
echo 0

