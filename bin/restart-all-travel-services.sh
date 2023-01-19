for p in travel-control travel-portal travel-agency; do oc get deploy -n $p -oname | xargs oc rollout restart -n $p; echo Waiting....; sleep 5; done
