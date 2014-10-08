#!/bin/bash -eu
./install_weave.sh
host_id=$1
echo ${host_id} > ~/.weave_host_id
shift
echo "Launching Weave"
echo  "sleep 1 ; weave launch \"10.0.0.$((100 + ${host_id}))/24\" $@" | at now

