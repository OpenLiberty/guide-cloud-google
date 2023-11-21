#!/bin/bash
while getopts t:d: flag;
do
    case "${flag}" in
        t) DATE="${OPTARG}";;
        d) DRIVER="${OPTARG}";;
        *) echo "Invalid choice";;
    esac
done

echo "Test latest OpenLiberty Docker image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/""$DATE""/""$DRIVER""</runtimeUrl></install></configuration>" system/pom.xml inventory/pom.xml
cat system/pom.xml inventory/pom.xml

sed -i "s;FROM openliberty/open-liberty:kernel-java8-openj9-ubi;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java11-openj9-ubi;g" inventory/Dockerfile system/Dockerfile
cat inventory/Dockerfile system/Dockerfile

docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-daily:full-java11-openj9-ubi"

sudo -u runner ../scripts/testApp.sh
