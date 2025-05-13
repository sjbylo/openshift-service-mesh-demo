#!/bin/bash 
# Steps to load the demo app - first, without the mesh

oc apply -f config/mesh3/travels-app-namespaces/
oc apply -f config-no-injection/travels-app     # Load the app and add to the mesh later

# The travels app manifests were copied from the great Travles demo on the Kiali website
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml -n travel-control
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml -n travel-agency
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml -n travel-portal

if oc get ConfigMap cluster-monitoring-config -n openshift-monitoring; then
	oc patch configmap cluster-monitoring-config -n openshift-monitoring --type merge -p '{"data":{"config.yaml":"enableUserWorkload: true\n"}}'
else
oc create -f - << END 
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
END
fi

sleep 1

for ns in travel-agency travel-portal travel-control
do
	oc get PodMonitor istio-proxies-monitor -n $ns || \
		oc get PodMonitor istio-proxies-monitor -n istio-system -o yaml | sed "s/namespace: istio-system/namespace: $ns/g" | oc apply -f -
done
#oc get PodMonitor istio-proxies-monitor -n istio-system -o yaml| sed "s/namespace: istio-system/namespace: travel-portal/g" | oc apply -f -
#oc get PodMonitor istio-proxies-monitor -n istio-system -o yaml| sed "s/namespace: istio-system/namespace: travel-control/g" | oc apply -f -

echo Waiting for Kiali route in istio-system ...
until oc -n istio-system get route | grep kiali
do
	sleep 8
done

# Wait for all pods to start 
bin/check-app-rollout.sh

echo
bin/check-app-working.sh

