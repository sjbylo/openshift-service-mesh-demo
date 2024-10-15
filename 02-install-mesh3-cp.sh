#!/bin/bash 
# Create the Service Mesh Control Plane (SMCP) resource to instatiate the mesh CP resources

. bin/include.sh

oc apply -Rf config/mesh3

echo This can take some time to complete.
echo -n Verifying installation ...

oc wait --for=jsonpath='{.status.state}'=Healthy Istio/default --timeout=120s
echo " done"

oc wait --for=jsonpath='{.status.state}'=Healthy IstioCni/default --timeout=120s
echo " done"

oc get -n istio-system Istio default -o jsonpath='{.status}' | jq .
#oc get Istio default -n istio-system

