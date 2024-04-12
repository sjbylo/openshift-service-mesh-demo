#!/bin/bash 
# Script will set up the GW, VS and DR for Travel demo.  Will auto find the correct ingress domain.

DOM=$1
[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`
[ "$DOM" ] || echo "Cannot determine the cluster domain: cannot access 'ingresses' 'cluster' resource. Something is wrong" >&2

echo Cluster domain is:
echo $DOM 
echo

# Adjust the 'hosts' value and apply the manifests 
for f in config/mesh/mesh-resources/control-*
do
	sed "s#CLUSTER_DOMAIN#$DOM#g" $f | oc apply -f - 
done

echo "Waiting for ingress route travel-control-control-gateway' to be available in 'istio-system' namespace ..."
while ! oc get route -n istio-system | grep -q ^travel-control-control-gateway 
do
	echo -n .
	sleep 1
done

# Now use the route in the istio-system namespace with a "." (the initial non-mesh-route had a "-") 
oc delete route control -n travel-control 2>/dev/null

sleep 8 

bin/check-app-working.sh

