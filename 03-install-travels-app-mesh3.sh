#!/bin/bash 
# Steps to load the demo app - first, without the mesh

oc apply -f config/mesh3/travels-app-namespaces/
oc apply -f config-no-injection/travels-app     # Load the app and add to the mesh later

# The travels app manifests were copied from the great Travles demo on the Kiali website
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml -n travel-control
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml -n travel-agency
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml -n travel-portal

oc patch configmap cluster-monitoring-config -n openshift-monitoring --type merge -p '{"data":{"config.yaml":"enableUserWorkload: true\n"}}'

oc get PodMonitor istio-proxies-monitor -n istio-system -o yaml| sed "s/namespace: istio-system/namespace: travel-agency/g" | oc apply -f -
oc get PodMonitor istio-proxies-monitor -n istio-system -o yaml| sed "s/namespace: istio-system/namespace: travel-portal/g" | oc apply -f -
oc get PodMonitor istio-proxies-monitor -n istio-system -o yaml| sed "s/namespace: istio-system/namespace: travel-control/g" | oc apply -f -

until oc -n istio-system get route | grep kiali
do
	sleep 8
done

# Wait for all pods to start 
bin/check-app-rollout.sh

echo
bin/check-app-working.sh

