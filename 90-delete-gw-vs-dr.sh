#!/bin/bash
# Script will delete the GW, VS and DR for Travel demo. 

oc delete -f config/mesh/mesh-resources

# Expose the app again
echo Exposing non-mesh route ...
oc expose service control -n travel-control

