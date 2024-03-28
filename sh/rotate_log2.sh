#!/bin/ksh
#rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]
numberOfFiles=10
while getopts "n:fltvecp:L:" opt; do
    case $opt in
  n) numberOfFiles="$OPTARG"
    if ! printf '%s\n' "$numberOfFiles" | grep '^[0-9][0-9]*$' >/dev/null;     then
      printf 'Numeric numberOfFiles required %s. rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]\n' "$numberOfFiles" 1>&2
      exit 1
    elif [ $numberOfFiles -lt 3 ]; then
      printf 'numberOfFiles < 3 %s. rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]\n' "$numberOfFiles" 1>&2
    fi
  ;;
  *) printf '-%s ignored. rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]\n' "$opt" 1>&2
  ;;
  esac
done
shift $(( $OPTIND - 1 ))
pathToLog="$1"
fileSize="$2"
if ! printf '%s\n' "$fileSize" | grep '^[0-9][0-9]*[BKMG]$' >/dev/null; then
  printf 'Numeric fileSize followed by B|K|M|G required %s. rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]\n' "$fileSize" 1>&2
  exit 1
fi
sizeQualifier=`printf "%s\n" "$fileSize" | sed "s%^[0-9][0-9]*\([BKMG]\)$%\1%"`
multip=1
case $sizeQualifier in
B) multip=1 ;;
K) multip=1024 ;;
M) multip=1048576 ;;
G) multip=1073741824 ;;
esac
fileSize=`printf "%s\n" "$fileSize" | sed "s%^\([0-9][0-9]*\)[BKMG]$%\1%"`
fileSize=$(( $fileSize * $multip ))
fileSize=$(( $fileSize / 1024 ))
if [ $fileSize -le 10 ]; then
  printf 'fileSize %sKB < 10KB. rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]\n' "$fileSize" 1>&2
  exit 1
fi
if ! touch "$pathToLog"; then
  printf 'Could not write to log file %s. rotatelogs.sh -n numberOfFiles pathToLog fileSize[B|K|M|G]\n' "$pathToLog" 1>&2
  exit 1
fi
lineCnt=0
while read line
do
  printf "%s\n" "$line" >>"$pathToLog"
  lineCnt=$(( $lineCnt + 1 ))
  if [ $lineCnt -gt 200 ]; then
    lineCnt=0
    curFileSize=`du -k "$pathToLog" | sed -e 's/^[  ][  ]*//' -e 's%[   ][  ]*$%%' -e 's/[  ][  ]*/[    ]/g' | cut -f1 -d" "`
    if [ $curFileSize -gt $fileSize ]; then
      DATE=`date +%Y%m%d_%H%M%S`
      cat "$pathToLog" | gzip -c >"${pathToLog}.${DATE}".gz && cat /dev/null >"$pathToLog"
      curNumberOfFiles=`ls "$pathToLog".[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].gz | wc -l | sed -e 's/^[   ][  ]*//' -e 's%[   ][  ]*$%%' -e 's/[  ][  ]*/[    ]/g'`
      while [ $curNumberOfFiles -ge $numberOfFiles ]; do
        fileToRemove=`ls "$pathToLog".[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].gz | head -1`
        if [ -f "$fileToRemove" ]; then
          rm -f "$fileToRemove"
          curNumberOfFiles=`ls "$pathToLog".[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].gz | wc -l | sed -e 's/^[   ][  ]*//' -e 's%[   ][  ]*$%%' -e 's/[  ][  ]*/[    ]/g'`
        else
          break
        fi
      done
    fi
  fi
done
