#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

cd config/certs/ingress 

openssl req -x509 -config cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:2048 -sha256 -keyout tls.key -out tls.crt

oc get secret istio-ingressgateway-certs -n istio-system && oc delete secret istio-ingressgateway-certs -n istio-system 

oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n istio-system

oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n istio-system

sed "s/FQDN/$DOM/g" < gateway.yaml | oc replace -f -


