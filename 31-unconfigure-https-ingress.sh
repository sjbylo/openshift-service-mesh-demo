#!/bin/bash -e

oc delete secret istio-ingressgateway-certs -n istio-system  || true

oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n istio-system

oc apply -f config/mesh/mesh-resources/control-gateway.yaml

sleep 3

bin/check-app-working.sh
