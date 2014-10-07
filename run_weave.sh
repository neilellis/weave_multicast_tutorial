#!/bin/bash -eu
host_id=$(<~/.weave_host_id)
weave launch "192.168.0.$((100 + ${host_id}))/24"
network="192.168.0.${host_id}/24"
echo "Network for this host is $network"
C=$(weave run $network -t -i weave-multicast-tutorial ./run.sh ${host_id})
echo "Container is $C"
#NSPID=$(docker inspect --format='{{ .State.Pid }}' $C)
#ln -s /proc/$NSPID/ns/net /var/run/netns/$NSPID
#ip netns exec $NSPID route add -net 224.0.0.0 netmask 240.0.0.0 dev ethwe
docker attach $C
