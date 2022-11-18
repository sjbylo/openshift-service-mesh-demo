#!/bin/bash -e
# Remove the mesh operators

# For how to properly remove operators, see:
# https://docs.openshift.com/container-platform/4.1/applications/operators/olm-deleting-operators-from-cluster.html#olm-deleting-operator-from-a-cluster-using-cli_olm-deleting-operators-from-a-cluster

# Double check no SMCP basic resource
oc get smcp basic -n istio-system 2>/dev/null && echo "Remove the Service Mesh Control Plane (SMCP) Custom Resource first" && exit 1

# Delete the operators 
for sub in jaeger-product kiali-ossm servicemeshoperator
do
	CSV=`oc get subscription $sub -n openshift-operators -o json | jq -r .status.currentCSV`	
	oc delete subscription $sub -n openshift-operators
	oc delete csv $CSV -n openshift-operators
done

echo 
echo To remove all leftover CRDs, run bin/cleanup-leftover-crds.sh 

