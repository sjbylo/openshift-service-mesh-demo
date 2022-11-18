# This will remove the travels app.  

oc delete -f config/travels-app-injected
oc delete -f config/travels-app-extension

# The manifests come from this great demo
#oc delete -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml -n travel-control
#oc delete -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml -n travel-agency
#oc delete -f https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml -n travel-portal

#oc delete -f https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v2.yaml -n travel-agency
#oc delete -f https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v3.yaml -n travel-agency

#oc delete route -n travel-control control

