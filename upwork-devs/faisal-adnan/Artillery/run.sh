#!/bin/sh
CONFIG_FILE=$1
NUMBER_OF_JOBS=$2

mkdir -p jobs

[ -f "artillery-conf.yml" ] && rm artillery-conf.yml
cp $CONFIG_FILE artillery-conf.yml

kubectl delete --ignore-not-found jobs -l jobgroup=artillery
kubectl delete --ignore-not-found secret artilleryconf
kubectl create secret generic artilleryconf --from-file=artillery-conf.yml

START=1
for (( c=$START; c<=$NUMBER_OF_JOBS; c++ ))
do
    echo "Submitting job $c"
    cat artillery-job-tmpl.yaml | sed "s/\$NO/$c/" > ./jobs/job-$c.yaml
    kubectl create -f ./jobs/job-$c.yaml
    rm ./jobs/job-$c.yaml
done
