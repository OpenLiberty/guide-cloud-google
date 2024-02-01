#!/bin/bash
set -euxo pipefail

mvn -ntp -pl system -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package liberty:create liberty:install-feature liberty:deploy
mvn -ntp -pl inventory -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package liberty:create liberty:install-feature liberty:deploy

mvn -ntp -pl system liberty:start
mvn -ntp -pl inventory liberty:start

mvn -ntp -pl system -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -Dsystem.node.port=9080 \
    failsafe:integration-test

mvn -ntp -pl inventory -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -Dsystem.node.port=9080 \
    -Dinventory.node.port=9081 \
    -Dsystem.kube.service=localhost \
    failsafe:integration-test

mvn -ntp -pl system liberty:stop
mvn -ntp -pl inventory liberty:stop

mvn -ntp failsafe:verify

