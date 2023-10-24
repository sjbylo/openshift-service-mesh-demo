#!/bin/bash -e

echo "This will send 90% of all traffic to v1 and 10% to v2 of travels api"
oc apply -R -f config/travels-app-canary-90-10

