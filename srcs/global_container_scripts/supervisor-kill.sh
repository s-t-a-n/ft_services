#!/bin/sh
printf "READY\n"; while read line; do pkill -9 supervisor; done < /dev/stdin
