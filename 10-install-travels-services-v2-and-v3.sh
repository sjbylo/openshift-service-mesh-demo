#!/bin/bash -e 

# Install the extra versions
oc apply -f config/travels-app-extension 

#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v2.yaml -n travel-agency
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v3.yaml -n travel-agency

# Script to add the auto-injection to all travel deployments
for ns in travel-control travel-agency travel-portal 
do
	echo "Injecting 'sidecar.istio.io/inject: true' into deployments in namespace $ns:"
	oc get deployment,dc -oname -n $ns \
		| xargs -L 1 oc patch --patch '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}' -n $ns
done

bin/check-app-rollout.sh

