#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

cd config/certs/ingress 
mkdir -p tmp

#sed "s/example.com/$DOM/g" < cert.cfg > tmp/cert.cfg

openssl req -x509 -config tmp/cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:2048 -sha256 -keyout tmp/tls.key -out tmp/tls.crt

oc get -n istio-system secret travel-control-credential && oc delete -n istio-system secret travel-control-credential 
oc create -n istio-system secret tls travel-control-credential --key=tmp/tls.key --cert=tmp/tls.crt

#oc get secret istio-ingressgateway-certs -n istio-system && oc delete secret istio-ingressgateway-certs -n istio-system 
#oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n istio-system
#oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n istio-system

sed "s/example.com/$DOM/g" < control-gateway-sds.yaml | oc replace -f -


