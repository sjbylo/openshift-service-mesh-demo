#!/bin/bash 

for d in cars-v1 discounts-v1 flights-v1 hotels-v1 insurances-v1 mysqldb-v1 travels-v1
do
	oc rollout status deployment $d -n travel-agency
done

for d in travels viaggi voyages
do
	oc rollout status deployment $d -n travel-portal
done

oc rollout status deployment control -n travel-control

for d in travels-v2 travels-v3
do
	oc rollout status deployment $d -n travel-agency
done

