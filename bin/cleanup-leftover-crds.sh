# Clean up *all* CR and CDR from the docs:
# https://docs.openshift.com/container-platform/4.11/service_mesh/v2x/removing-ossm.html#ossm-control-plane-remove-cli_removing-ossm

oc delete validatingwebhookconfiguration/openshift-operators.servicemesh-resources.maistra.io
oc delete mutatingwebhookconfiguration/openshift-operators.servicemesh-resources.maistra.io
oc delete svc maistra-admission-controller -n openshift-operators
oc -n openshift-operators delete ds -lmaistra-version
oc delete clusterrole/istio-admin clusterrole/istio-cni clusterrolebinding/istio-cni
oc delete clusterrole istio-view istio-edit
oc delete clusterrole jaegers.jaegertracing.io-v1-admin jaegers.jaegertracing.io-v1-crdview jaegers.jaegertracing.io-v1-edit jaegers.jaegertracing.io-v1-view
( oc get crds -o name | grep '.*\.istio\.io' | xargs -r -n 1 oc delete ) 
( oc get crds -o name | grep '.*\.maistra\.io' | xargs -r -n 1 oc delete ) 
( oc get crds -o name | grep '.*\.kiali\.io' | xargs -r -n 1 oc delete ) 
oc delete crds jaegers.jaegertracing.io
oc delete cm -n openshift-operators maistra-operator-cabundle
oc delete cm -n openshift-operators istio-cni-config
oc delete sa -n openshift-operators istio-cni


