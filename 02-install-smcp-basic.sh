#!/bin/bash 
# Create the Service Mesh Control Plane (SMCP) resource to instatiate the mesh CP resources

. bin/include.sh

oc apply -f config/mesh/basic-mesh
#[ $? -ne 0 ] && echo Waiting for webhook to become available ... && \
#   while ! oc apply -f config/mesh/basic-mesh 2>/dev/null; do echo -n .; sleep 1; done  # This is due to the error "Internal error occurred: failed calling webhook"

echo This can take some time to complete.
echo -n Verifying installation ...

oc wait -n istio-system --for=condition=ready smcp basic --timeout=400s

#while ! oc get smcp basic -n istio-system | grep -qi ComponentsReady
#do
#	echo -n .
#	sleep 1
#done
echo " done"

oc get smcp basic -n istio-system

# Wait for route/kiali to be created
echo -n "Waiting for route/kiali ..."
try_cmd 2 1 60 "oc get route kiali -n istio-system 2>/dev/null" || exit 1

echo " done"

echo
echo "Kiali route:"
echo "https://`oc get route kiali -n istio-system -o json | jq -r .spec.host`"

