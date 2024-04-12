#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

cd config/certs/ingress 
mkdir -p tmp

# If you replace the example.com with something long you get an ssl error
sed "s/example.com/$DOM/g" < cert.cfg > tmp/cert.cfg
openssl req -x509 -config tmp/cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:4096 -sha256 -keyout tmp/tls.key -out tmp/tls.crt

oc get secret istio-ingressgateway-certs -n istio-system && oc delete secret istio-ingressgateway-certs -n istio-system 
sleep 1

oc create secret tls istio-ingressgateway-certs --cert tmp/tls.crt --key tmp/tls.key -n istio-system
sleep 1

oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n istio-system

sed "s/example.com/$DOM/g" < control-gateway.yaml | oc replace -f -


sleep 8

h=$(oc get route -n istio-system | grep travel-control-control-gateway | awk '{print $2}')
#h=$(oc get route travel-control -o json | jq -r .spec.host)
curl -sk https://$h/ | grep "Travel Control" && echo && echo "App available at 'https://$h/'" && exit
echo "Can't reach app at https://$h/"
