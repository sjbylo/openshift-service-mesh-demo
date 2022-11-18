#!/bin/bash 

echo Executing the following commands:
execscripts=./9[0-8]*sh

ls -1 $execscripts
echo -n "Continue (y/n) [y]:"
read yn 
[ "$yn" == "n" ] && exit 

for s in $execscripts
do
	echo ==========================
	echo $s
	echo ==========================
	eval $s

	sleep 1
done
