#!/bin/bash 
# Delete the mesh control plane infra

oc delete -f config/mesh/basic-mesh
#oc delete smcp basic -n istio-system

# Need to verify all pods have been removed 
echo -n Verifying deletion of all control-plane pods ...
while [ `oc get po -n istio-system --no-headers 2>/dev/null | wc -l` -ne 0 ]
do
	echo -n .
	sleep 1
done

echo " done"

