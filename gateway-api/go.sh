#!/bin/bash 
# This script ONLY works (as-is) on 4.19 and above.

echo_red()   { tput setaf 1; echo -e "$*"; tput sgr0; }
echo_green() { tput setaf 3; echo -e "$*"; tput sgr0; }


! oc get Istio -A --no-headers | grep -qi healthy && echo_red "Must install OSSM 3.x" && exit 1

APPS_DOM=$(oc get ingress.config/cluster -o jsonpath='{.spec.domain}{"\n"}')
echo_green Domain=$APPS_DOM

echo
echo_green Install httpbin app
oc create namespace httpbin

oc apply -n httpbin -f https://raw.githubusercontent.com/openshift-service-mesh/istio/refs/heads/master/samples/httpbin/httpbin.yaml

echo
echo_green Configure gateway
cat httpbin-gw.yaml | sed "s/hostname: .*/hostname: httpbin.$APPS_DOM/g" | oc apply -f -
#oc apply -f httpbin-gw.yaml

oc apply -f httpbin-hr.yaml

oc wait --for=condition=programmed gtw httpbin-gateway -n httpbin

echo
echo_green Internal test with curl 
oc create namespace curl

oc apply -n curl -f https://raw.githubusercontent.com/openshift-service-mesh/istio/refs/heads/master/samples/curl/curl.yaml

sleep 1

CURL_POD=$(oc get pods -n curl -l app=curl -o jsonpath='{.items[*].metadata.name}')

curl_pod_check() {
	oc exec $CURL_POD -n curl -- \
		curl -s -I \
		-H Host:httpbin.$APPS_DOM \
		httpbin-gateway-istio.httpbin.svc.cluster.local/headers
}

curl_pod_check
! curl_pod_check | grep -q "200 OK" && echo_red "ERROR: Expecting '200 OK' responce" && exit 1

oc patch service httpbin-gateway-istio -n httpbin -p '{"spec": {"type": "LoadBalancer"}}'

sleep 1

echo
echo_green Test with external LB
export INGRESS_HOST=$(oc get gtw httpbin-gateway -n httpbin -o jsonpath='{.status.addresses[0].value}')
INGRESS_PORT=$(oc get gtw httpbin-gateway -n httpbin -o jsonpath='{.spec.listeners[?(@.name=="http")].port}')

echo_green "Waiting for endpoint to become available: http://$INGRESS_HOST:$INGRESS_PORT ..."
until curl -s -I -H Host:httpbin.$APPS_DOM http://$INGRESS_HOST:$INGRESS_PORT/headers; do sleep 5; echo -n .; done

echo_green "Call: curl -s -I -H Host:httpbin.$APPS_DOM http://$INGRESS_HOST:$INGRESS_PORT/headers"
echo_green "(This only works if 'LoadBalancer' type services are working in your cluster!)"
echo

curl -s -I -H Host:httpbin.$APPS_DOM http://$INGRESS_HOST:$INGRESS_PORT/headers
! curl -s -I -H Host:httpbin.$APPS_DOM http://$INGRESS_HOST:$INGRESS_PORT/headers | grep -q "200 OK" && echo_red "ERROR: Expecting '200 OK' responce" && exit 1

echo_green Creating route 
cat httpbin-route.yaml | sed "s/host: .*/host: httpbin.$APPS_DOM/g" | oc apply -f -
echo_green "Running: curl -s -I http://httpbin.$APPS_DOM/headers"
curl -s -I http://httpbin.$APPS_DOM/headers 
! curl -s -I http://httpbin.$APPS_DOM/headers | grep -q "200 OK" && echo_red "ERROR: Expecting '200 OK' responce" && exit 1

sleep 1

echo_green SUCCESS!
echo_green Route: http://httpbin.$APPS_DOM/headers
echo_green LB: httpbin.$APPS_DOM via http://$INGRESS_HOST:$INGRESS_PORT/headers
oc get po -n httpbin


