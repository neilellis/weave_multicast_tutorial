#!/bin/bash -eu
./install_weave.sh
ufw allow 6783fdsfds
host_id="${1}"
shift
echo ${host_id} > ~/.weave_host_id
echo "Launching Weave"
echo  "sleep 2 ; weave launch \"10.0.0.$((100 + ${host_id}))/24\" $@" | at now

