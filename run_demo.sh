#!/bin/bash -eu
host_id=$(< ~/.weave_host_id)
network="10.0.0.${host_id}/24"
echo "Network for this host is $network"
weave run $network -t -i neilellis/weave-multicast-tutorial /run.sh ${host_id}
docker ps --no-trunc | grep  weave-multicast-tutorial | cut -d" " -f1 > ~/.container_id
sleep 5
docker logs $(cat ~/.container_id)
