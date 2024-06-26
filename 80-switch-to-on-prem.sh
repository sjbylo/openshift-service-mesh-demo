#!/bin/bash -ex
# This script will switch the registry for testing only

# Fix the sources
sed -i "s/source: .*/source: cs-redhat-operator-index/g" operators/*

# Fix the registry 
reg_host=registry.example.com
reg_port=8443
reg_path=ocp4/openshift4
set +x
sed -i "s#quay\.io#$reg_host:$reg_port/$reg_path#g" */*.yaml */*/*.yaml */*/*/*.yaml

