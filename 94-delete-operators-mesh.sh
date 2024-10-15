#!/bin/bash 
# Remove the mesh operators

# For how to properly remove operators, see:
# https://docs.openshift.com/container-platform/4.1/applications/operators/olm-deleting-operators-from-cluster.html#olm-deleting-operator-from-a-cluster-using-cli_olm-deleting-operators-from-a-cluster

# Double check no SMCP basic resource
#oc get smcp basic -n istio-system 2>/dev/null && echo "Remove the Service Mesh Control Plane (SMCP) Custom Resource first" && exit 1

# Delete the operators 
#for sub in jaeger-product kiali-ossm servicemeshoperator
for sub in                kiali-ossm servicemeshoperator3
do
	# Note that if ACM is installed there can be a conflict between "subcriptions" and "subs" which are different APIs!
	oc get subs $sub -n openshift-operators 
	CSV=`oc get subs $sub -n openshift-operators -o json | jq -r .status.currentCSV`	
	oc delete subs $sub -n openshift-operators
	[ "$CSV" ] && oc delete csv $CSV -n openshift-operators || echo "No csv object found in: subs $sub -n openshift-operators"
done

# Hammer method!  Sometimes "status.currentCSV" does not exist due to misconfiguration. 
oc get csv -n openshift-operators -oname | cut -d/ -f2 | grep -e ^kiali-operator -e ^servicemeshoperator3 -e ^jaeger-operator | xargs -L1 oc delete -n openshift-operators csv || true

echo 
echo To remove all leftover CRDs, run bin/cleanup-leftover-crds.sh 

