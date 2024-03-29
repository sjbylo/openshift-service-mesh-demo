#!/bin/bash

# Note that '90-delete-gw-vs-dr.sh' can bes used to reset this config

# Be sure this has been executed ok
./06-add-gw-vs-dr.sh

# This sets up the gw obj needed for https with a secret (cert) 
./40-configure-https-ingress-with-sds.sh


# This deploys an Envoy ingress pod in the travel-control ns (gw better NOT in istio-system ns) 
oc apply -f config/certs/ingress/gateway-injection.yaml


# This is the 'passthrough" route that's needed, basically the same at the route in istio-system ns
oc apply -f - << END 
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: travel-control
  namespace: travel-control
spec:
  port:
    targetPort: https
  tls:
    termination: passthrough
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  wildcardPolicy: None
END

sleep 8

h=$(oc get route travel-control -o json | jq -r .spec.host)
curl -sk https://$h/ | grep "Travel Control" && echo && echo "App available at 'https://$h/'"

