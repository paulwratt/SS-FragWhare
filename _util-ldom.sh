#!/bin/sh
# ldom.sh - created with 'mkshcmd'

if [ "$1" = "--help" -o "$1" = "-h" -o "$1" = "" ]; then
  echo "Last Day of Month"
  echo " outputs the last numerical day of the month"
  echo "usage: ldom.sh [now|_date_]"
  echo "options:"
  echo "  now           as of the current month"
  echo "  _date_        either '2022-02' or '2022-02-25'"
  exit 0
fi

D="$1"
if [ "$D" = "now" ]; then
  D="$(date -Iseconds | cut -d \T -f 1)"
fi

X="$(echo $D | cut -d \- -f 2)"
if [ "$X" = "" ]; then
  echo "error: not a valid date '$D'"
  exit
fi
if [ "$X" = "$D" ]; then
  echo "error: not a valid date '$D'"
  exit
fi
if [ $X -lt 1 ]; then
  echo "error: not a valid month '$D'"
  exit
fi
if [ $X -gt 12 ]; then
  echo "error: not a valid month '$D'"
  exit
fi
if [ $(echo $D | cut -d \- -f 1 | wc -c) -ne 5 ]; then
  echo "error: not a full year '$D'"
  exit
fi

isLeapYear () {
  if [ $(($1 % 4)) -eq 0 -a ! $(($1 % 100)) -eq 0 ]; then
    return 0
  elif [ $(($1 % 400)) -eq 0 ]; then
    return 0
  fi
  return 1
}

lastDayOfMonth () {
  Y=$(echo $1 | cut -d \- -f 1)
  M=$(echo $1 | cut -d \- -f 2)
  case $M in
    1|01)  DoM=31 ;;       # January
    3|03)  DoM=31 ;;       # March
    5|05)  DoM=31 ;;       # May
    7|07)  DoM=31 ;;       # July
    8|08)  DoM=31 ;;       # August
    10)    DoM=31 ;;       # October
    12)    DoM=31 ;;       # December
    2|02)  DoM=28          # February
           isLeapYear "$Y" && DoM=29
                  ;;
    *)     DoM=30 ;;       # April, June, September, November
  esac
  echo "$DoM"
}

lastDayOfMonth "$D"

exit 0

