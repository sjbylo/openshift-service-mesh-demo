oc create sa travels
oc create sa hotels
oc create sa cars
oc create sa discounts
oc create sa flights
oc create sa insurances
oc create sa mysqldb
oc set serviceaccount deployment/travels-v1 travels
oc set serviceaccount deployment/travels-v2 travels
oc set serviceaccount deployment/travels-v3 travels
oc set serviceaccount deployment/hotels-v1 hotels
oc set serviceaccount deployment/cars-v1 cars
oc set serviceaccount deployment/discounts-v1 discounts
oc set serviceaccount deployment/flights-v1 flights
oc set serviceaccount deployment/insurances-v1 insurances
oc set serviceaccount deployment/mysqldb-v1 mysqldb
