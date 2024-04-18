#!/bin/bash -e

[ "$DOM" ] || DOM=`oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

##cd config/certs/ingress 
##rm -rf tmp  # do not delete. cert.cfg created by other script!
mkdir -p tmp

sed "s/example.com/$DOM/g" < cert.cfg > tmp/cert.cfg

openssl req -x509 -config tmp/cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:4096 -sha256 -keyout tmp/tls.key -out tmp/tls.crt

oc get -n httpbin-demo secret httpbin-credential && oc delete -n httpbin-demo secret httpbin-credential 
oc create -n httpbin-demo secret tls httpbin-credential --key=tmp/tls.key --cert=tmp/tls.crt

#oc get secret istio-ingressgateway-certs -n httpbin-demo && oc delete secret istio-ingressgateway-certs -n httpbin-demo 
#oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n httpbin-demo

oc get gw httpbin-gateway && \
sed "s/example.com/$DOM/g" < httpbin-gateway-sds.yaml | oc replace -f - || \
sed "s/example.com/$DOM/g" < httpbin-gateway-sds.yaml | oc create -f - 

oc apply -f httpbin-dr.yaml  
oc apply -f httpbin-vs.yaml

# This deploys an Envoy ingress pod in the travel-control ns (gw better NOT in istio-system ns) 
oc apply -f gateway-injection.yaml

# This is the 'passthrough" route that's needed, basically the same at the route in istio-system ns
oc delete route httpbin
oc apply -f - << END 
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: httpbin
  namespace: httpbin-demo
spec:
  port:
    targetPort: https
  tls:
#    termination: reencrypt
    termination: passthrough
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  wildcardPolicy: None
END

exit 

sleep 3
oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n httpbin-demo

h=$(oc get route -n httpbin-demo | grep httpbin-gateway | awk '{print $2}')
#h=$(oc get route httpbin -o json | jq -r .spec.host)
curl -sk https://$h/ | grep -i "httpbin" && echo && echo "App available at 'https://$h/'" && exit
echo "Can't reach app at https://$h/"

