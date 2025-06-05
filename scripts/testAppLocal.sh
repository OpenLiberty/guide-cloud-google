#!/bin/bash
set -euxo pipefail

./mvnw -version

./mvnw -ntp -pl system -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package liberty:create liberty:install-feature liberty:deploy
./mvnw -ntp -pl inventory -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package liberty:create liberty:install-feature liberty:deploy

./mvnw -ntp -pl system liberty:start
./mvnw -ntp -pl inventory liberty:start

./mvnw -ntp -pl system -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -Dsystem.node.port=9080 \
    failsafe:integration-test

./mvnw -ntp -pl inventory -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -Dsystem.node.port=9080 \
    -Dinventory.node.port=9081 \
    -Dsystem.kube.service=localhost \
    failsafe:integration-test

./mvnw -ntp -pl system liberty:stop
./mvnw -ntp -pl inventory liberty:stop

./mvnw -ntp failsafe:verify

