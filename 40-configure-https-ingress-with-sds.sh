#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

cd config/certs/ingress 
##rm -rf tmp  # do not delete. cert.cfg created by other script!
mkdir -p tmp

sed "s/example.com/$DOM/g" < cert.cfg > tmp/cert.cfg

openssl req -x509 -config tmp/cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:4096 -sha256 -keyout tmp/tls.key -out tmp/tls.crt

oc get -n istio-system secret travel-control-credential && oc delete -n istio-system secret travel-control-credential 
oc create -n istio-system secret tls travel-control-credential --key=tmp/tls.key --cert=tmp/tls.crt

#oc get secret istio-ingressgateway-certs -n istio-system && oc delete secret istio-ingressgateway-certs -n istio-system 
#oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n istio-system

sed "s/example.com/$DOM/g" < control-gateway-sds.yaml | oc replace -f -

sleep 3
oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n istio-system

h=$(oc get route -n istio-system | grep travel-control-control-gateway | awk '{print $2}')
#h=$(oc get route travel-control -o json | jq -r .spec.host)
curl -sk https://$h/ | grep "Travel Control" && echo && echo "App available at 'https://$h/'" && exit
echo "Can't reach app at https://$h/"
