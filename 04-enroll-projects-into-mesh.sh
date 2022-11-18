#!/bin/bash 
# Steps to add app to the mesh

oc apply -f config/mesh/mesh-members

sleep 1

echo Verifying ... 
oc get smmr default -n istio-system -o yaml| grep " configuredMembers:" -A3 

