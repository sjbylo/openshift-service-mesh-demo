#!/bin/bash -e
# Use this to verify the token: https://jwt.io/ 

INGRESS_ROUTE=`oc get route -n istio-system istio-ingressgateway -o jsonpath='{.spec.host}'`

oc delete AuthorizationPolicy frontend-ingress -n istio-system >/dev/null 2>&1
sleep 1

# This should succeed (200), unless AuthorizationPolicy-require-valid-token.yaml is applied (403)
echo -n "Test if request without a token succeeds "
#curl "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"
RES=`curl "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
[ "$RES" = "200" ] && echo $RES OK || echo $RES FAIL, "(should be 200)"

oc create -f require-valid-token/AuthorizationPolicy-frontend-ingress.yaml >/dev/null
sleep 3

# This should fail (403)
echo -n "Test without AuthorizationPolicy restriction "
RES=`curl "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
#curl "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"
[ "$RES" = "403" ] && echo $RES OK || echo $RES FAIL, "(should be 403)"


# This should fail (401)
echo -n "Test with invalid token "
RES=`curl --header "Authorization: Bearer bad.dead.beef" "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
[ "$RES" = "401" ] && echo $RES OK || echo $RES FAIL, "(should be 401)"

oc replace -f require-valid-token-and-claim/AuthorizationPolicy-frontend-ingress.yaml >/dev/null
sleep 3

# Use token which includes the correct claim, "group".  This should succeed 200
TOKEN_GROUP=$(curl https://raw.githubusercontent.com/istio/istio/release-1.9/security/tools/jwt/samples/groups-scope.jwt -s) 
#TOKEN_GROUP=`python3 ./gen-jwt.py  --iss testing@secure.istio.io --aud foo,bar --claims=email:foo@google.com,a:b key.pem -listclaim groups group1 group2 -listclaim x y 2>/dev/null`
echo -n "Test with valid token with group claim "
RES=`curl --header "Authorization: Bearer $TOKEN_GROUP" "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
[ "$RES" = "200" ] && echo $RES OK || echo $RES FAIL, "(should be 200)"



# Use token which DOES NOT include the correct claim, "group".  This should fail 
TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.17/security/tools/jwt/samples/demo.jwt -s)
#TOKEN=`python3 ./gen-jwt.py --iss testing@secure.istio.io key.pem 2>/dev/null`
echo -n "Test with token with NO group claim "
RES=`curl --header "Authorization: Bearer $TOKEN" "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
[ "$RES" != "200" ] && echo $RES OK || echo $RES FAIL, "(should be 200)"

oc replace -f require-valid-token/AuthorizationPolicy-frontend-ingress.yaml >/dev/null

echo -n "Test expiration. "
TOKEN=$(python3 ./gen-jwt.py ./key.pem --expire 5 2>/dev/null)
#TIME_EXP=`echo $TOKEN | cut -d '.' -f2 - | base64 --decode -| jq .exp`
TIME_EXP=`echo $TOKEN | cut -d '.' -f2 - | base64 -D | jq .exp`
TIME_NOW=`date +%s`
echo This token should expire in `expr $TIME_EXP - $TIME_NOW` seconds ...
time (RET=`curl --header "Authorization: Bearer $TOKEN" "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
while [ "$RET" = "200" ]
do
	RET=`curl --header "Authorization: Bearer $TOKEN" "$INGRESS_ROUTE/headers" -s -o /dev/null -w "%{http_code}\n"`
	printf "\r$RET ."
	sleep .1
	printf "\r$RET "
	sleep .1
done)
echo "$RET "

# This may seem to take longer to expire

# Example payload (TOKEN_GROUP) 
# 
# curl https://raw.githubusercontent.com/istio/istio/release-1.9/security/tools/jwt/samples/groups-scope.jwt -s | cut -d '.' -f2 - | base64 --decode -| jq .
# {
#   "exp": 3537391104,
#   "groups": [
#     "group1",
#     "group2"
#   ],
#   "iat": 1537391104,
#   "iss": "testing@secure.istio.io",
#   "scope": [
#     "scope1",
#     "scope2"
#   ],
#   "sub": "testing@secure.istio.io"
# }


