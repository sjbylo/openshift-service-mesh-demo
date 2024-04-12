#!/bin/bash

oc delete -f config/certs/ingress/gateway-injection.yaml
./90-delete-gw-vs-dr.sh

oc delete route travel-control

./06-add-gw-vs-dr.sh

