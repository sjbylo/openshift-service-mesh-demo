# Script will remove the namespcaes needed for the application in the mesh

oc delete -f config/mesh/mesh-members
sleep 1
oc delete project travel-agency travel-control travel-portal

