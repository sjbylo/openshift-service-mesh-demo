#!/bin/bash 
# Steps to load the demo app - first, without the mesh

oc apply -f config/mesh/travels-app-namespaces/
oc apply -f config-no-injection/travels-app     # Load the app and add to the mesh later

# The travels app manifests were copied from the great Travles demo on the Kiali website
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml -n travel-control
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml -n travel-agency
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml -n travel-portal

# Wait for all pods to start 
bin/check-app-rollout.sh

echo
bin/check-app-working.sh

