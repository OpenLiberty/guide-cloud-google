#!/bin/bash
set -euxo pipefail

# Test app

mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q package

docker build -t system:test system/.
docker build -t inventory:test inventory/.

kubectl apply -f ../scripts/test.yaml

sleep 120

kubectl get pods

minikube ip

GUIDE_IP=$(minikube ip)
GUIDE_SYSTEM_PORT=$(kubectl get service system-service -o jsonpath="{.spec.ports[0].nodePort}")
GUIDE_INVENTORY_PORT=$(kubectl get service inventory-service -o jsonpath="{.spec.ports[0].nodePort}")

curl "http://$GUIDE_IP:$GUIDE_SYSTEM_PORT/system/properties"

curl "http://$GUIDE_IP:$GUIDE_INVENTORY_PORT/inventory/systems/system-service"

mvn failsafe:integration-test -Dcluster.ip="$GUIDE_IP"
mvn failsafe:verify

kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)"
kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)"

# Clear .m2 cache and remove from kubectl
kubectl delete -f ../scripts/test.yaml
rm -rf ~/.m2
