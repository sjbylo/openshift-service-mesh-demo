#!/bin/bash 
# Install the needed operators (ElasticSearch not needed for this demo) 

oc apply -f operators

# Note, the above operator manifests are from the Travels demo on the Kiali website: https://kiali.io/docs/tutorials/travels/
#oc apply -f https://raw.githubusercontent.com/kiali/demos/master/federated-travels/ossm-subs.yaml

echo This can take some time to complete.
echo -n Verifying Operator installation ...

#while [ `oc get csv -n openshift-operators 2>/dev/null | grep -e "^jaeger-operator\." -e  "^kiali-operator\." -e "^servicemeshoperator\." | grep "\bSucceeded\b" | wc -l` -ne 3 ]
while [ `oc get csv -n openshift-operators 2>/dev/null | grep -e "^kiali-operator\." -e "^servicemeshoperator\." | grep "\bSucceeded\b" | wc -l` -ne 2 ]
do
	echo -n . 
	sleep 1
done

echo " done"

oc get csv -n openshift-operators | grep -e "^jaeger-operator\." -e  "^kiali-operator\." -e "^servicemeshoperator\."

# Note: Can't create SMCP resource (next step) if the operator is not fully ready
### echo -n Waiting for Istio Operator to become fully ready ...
### 
### while ! oc logs `oc get po -n openshift-operators -oname -l name=istio-operator` -n openshift-operators | grep -qi "Correct CABundle already present" 
### do
###	echo -n .
###	sleep 2
###done

echo " done"

