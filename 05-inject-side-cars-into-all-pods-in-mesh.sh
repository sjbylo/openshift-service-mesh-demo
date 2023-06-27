#!/bin/bash 
# Add travels app into the mesh

# Note that the following would also work:
# oc label namespace travel-control travel-agency travel-portal istio-injection=enabled 

# Script to add the auto-injection to all travel deployments 
for ns in travel-control travel-agency travel-portal 
do
	echo "Injecting 'sidecar.istio.io/inject: true' into deployments in namespace $ns:"
	oc get deployment,dc -oname -n $ns \
		| xargs -L 1 oc patch --patch '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "'true'"}}}}}' -n $ns
done

# Wait for pods to restart 
bin/check-app-rollout.sh

