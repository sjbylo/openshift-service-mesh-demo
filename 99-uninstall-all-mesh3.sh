#!/bin/bash 

echo Executing the following commands:
echo
echo oc delete -Rf config/mesh3
echo 94-delete-operators-mesh.sh
echo
echo -n "Continue (y/n) [y]:"
read yn 
[ "$yn" == "n" ] && exit 

oc delete -Rf config/mesh3
./94-delete-operators-mesh3.sh
