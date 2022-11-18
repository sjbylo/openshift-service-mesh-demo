#!/bin/bash -e 

# Install the extra versions
oc delete -f config/travels-app-extension 

bin/check-app-rollout.sh
