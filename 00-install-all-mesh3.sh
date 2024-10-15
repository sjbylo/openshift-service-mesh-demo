#!/bin/bash 

# Note: use this to change the name of the istio system ns
#sed -i "s/istio-system/istio-system/g" `find * -type f -exec grep -l "\bistio-system\b" {} \;`

echo Executing the following commands:

execscripts="\
./01-install-operators-mesh3.sh
./02-install-mesh3-cp.sh
./03-install-travels-app-mesh3.sh
./06-add-gw-vs-dr.sh
./10-install-travels-services-v2-and-v3.sh
./11-add-per-portal-routing-to-travels-v1-v2-v3.sh
./12-remove-per-portal-routing-to-travels-v1-v2-v3.sh
./20-inject-delay-into-flight-svc.sh
./41-configure-gateway-injection.sh
"
#execscripts="$execscripts ./41-configure-gateway-injection.sh ./10-install-travels-services-v2-and-v3.sh ./11-add-per-portal-routing-to-travels-v1-v2-v3.sh ./20-inject-delay-into-flight-svc.sh"

ls -1 $execscripts
echo -n "Continue (y/n) [y]:"
read yn 
[ "$yn" == "n" ] && exit 

for s in $execscripts
do
	echo ==========================
	echo $s
	echo ==========================

	eval $s
	sleep 1
done

echo
bin/check-app-working.sh

