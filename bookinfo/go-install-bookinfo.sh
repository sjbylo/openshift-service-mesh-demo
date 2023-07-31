oc create -f conf/1-ns
sleep 2
oc create -f conf/2-app -n bookinfo 

oc create -f conf/3-istio/ -n bookinfo 
