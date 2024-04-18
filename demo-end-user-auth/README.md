# Istio JWT Demo Setup 
# FOR THIS TO WORK AT ALL, NEED TO DELETE ALL Travles app config (app, vs, dr, ns...)

```
oc create -R -f conf/1-app-mesh/
sleep 2                            # Need to wait for the project to become part of the mesh!
oc create -R -f conf/2* -n foo
oc create -R -f conf/3* -n foo

```

# Cleanup

```
oc delete -R -f conf
```

# Run tests

See the file test.sh for how to configure JWT in Istio.

Run the tests:

Note: you may need to install the lib:
`pip install jwcrypto`

```
bash ./test.sh 
Test if request without a token succeeds 200 OK
Test without AuthorizationPolicy restriction 403 OK
Test with invalid token 401 OK
Test with valid token with group claim 200 OK
Test with token with NO group claim 403 OK
Test expiration This token should expire in 5 seconds ...
200 .
```

# How to use the token generator:

```
python3 ./gen-jwt.py  --iss example-issuer --aud foo,bar --claims=email:foo@google.com,dead:beef key.pem -listclaim key1 val2 val3 -listclaim key2 val3 val4 | cut -f2 -d. | base64 -d | jq . 
```

