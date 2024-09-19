#!/bin/bash 
# Problem: this script will show the Kiali route below even if the app is not in the mesh (no GW, VS etc)

echo -n "Use this URL to access the demo app "

APP_URL=`oc get route control -n travel-control -o json 2>/dev/null | jq -r .status.ingress[0].host`
if [ "$APP_URL" ]; then
	echo 
	echo "http://$APP_URL/"
	curl -L $APP_URL 2>/dev/null | grep -q "Travel Control Dashboard" && echo "Demo app is working!" || echo "Demo app is not working!"
else
	APP_URL=`oc get route travel-control -n travel-control -o json 2>/dev/null | jq -r .status.ingress[0].host`
	if [ "$APP_URL" ]; then
		echo via the injected gateway
		echo "https://$APP_URL/"
		curl -kL https://$APP_URL 2>/dev/null | grep -q "Travel Control Dashboard" && echo "Demo app is working!" || echo "Demo app is not working!"
	else
		# Fetch the mesh ingress route
		APP_URL=`oc get route -n istio-system | grep ^travel-control-control-gateway | awk '{print $2}'`
		if [ "$APP_URL" ]; then
			echo via the mesh ingress gateway
			echo http://$APP_URL
			curl -L $APP_URL 2>/dev/null | grep -q "Travel Control Dashboard" && echo "Demo app is working!" || echo "Demo app is not working!"
		else
			echo 
			echo "No route available"
		fi
	fi
fi

K=`oc get route kiali -n istio-system -o json | jq -r ".spec.host"`

if [ "$K" ]; then
	# Show Kiali route 
	echo
	echo Note, it may take a few minutes for the demo app graph to show up in your browser.
	echo "Kiali route:"
	echo "https://$K/"
	echo
	echo Wait a few minutes and go directly to the demo graph with animation settings turned on:
	echo "https://$K/console/graph/namespaces/?traffic=grpc%2CgrpcRequest%2Chttp%2ChttpRequest%2Ctcp%2CtcpSent&graphType=versionedApp&namespaces=travel-agency%2Ctravel-control%2Ctravel-portal&duration=60&refresh=10000&layout=dagre&namespaceLayout=kiali-dagre&animation=true&injectServiceNodes=false&graphFind=rt+%3E+1000&edges=responseTime%2Crt95"

fi

