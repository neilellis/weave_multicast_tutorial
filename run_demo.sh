#!/bin/bash -eux
host_id=$(<~/.weave_host_id)
network="10.0.0.${host_id}/24"
echo "Network for this host is $network"
weave run $network -t -i cazcade/weave-multicast-tutorial /run.sh ${host_id}
docker ps | grep  a | head -1 | cut -d" " -f1 > ~/.container_id

#NSPID=$(docker inspect --format='{{ .State.Pid }}' $C)
#ln -s /proc/$NSPID/ns/net /var/run/netns/$NSPID
#ip netns exec $NSPID route add -net 224.0.0.0 netmask 240.0.0.0 dev ethwe

