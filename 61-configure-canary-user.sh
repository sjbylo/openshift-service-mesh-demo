#!/bin/bash -e

echo "This will send traffic from the UK portal to v2."
oc apply -R -f config/travels-app-canary-user

