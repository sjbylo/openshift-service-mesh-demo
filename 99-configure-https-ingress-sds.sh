#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

cd config/certs/ingress 
mkdir -p tmp

sed "s/example.com/$DOM/g" < cert.cfg > tmp/cert.cfg

openssl req -x509 -config tmp/cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:4096 -sha256 -keyout tmp/tls.key -out tmp/tls.crt

oc get -n travel-control secret travel-control-credential && oc delete -n travel-control secret travel-control-credential 
oc create -n travel-control secret tls travel-control-credential --key=tmp/tls.key --cert=tmp/tls.crt

#oc get secret istio-ingressgateway-certs -n travel-control && oc delete secret istio-ingressgateway-certs -n travel-control 
#oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n travel-control
#oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n travel-control

sed "s/example.com/$DOM/g" < control-gateway-sds.yaml | oc replace -f -


