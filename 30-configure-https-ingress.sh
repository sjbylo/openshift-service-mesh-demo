#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

cd config/certs/ingress 
mkdir -p tmp

# If you replace the example.com with something long you get an ssl error
#sed "s/example.com/$DOM/g" < tmp/cert.cfg > tmp/cert.cfg
openssl req -x509 -config tmp/cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:2048 -sha256 -keyout tmp/tls.key -out tmp/tls.crt

oc get secret istio-ingressgateway-certs -n istio-system && oc delete secret istio-ingressgateway-certs -n istio-system 

oc create secret tls istio-ingressgateway-certs --cert tmp/tls.crt --key tmp/tls.key -n istio-system

oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n istio-system

sed "s/example.com/$DOM/g" < control-gateway.yaml | oc replace -f -


