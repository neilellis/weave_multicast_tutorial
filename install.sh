#!/bin/bash -eu
./install_weave.sh
echo $1 > ~/.weave_host_id
echo "Launching Weave"
echo  "sleep 10 ; weave launch \"10.0.0.$((100 + ${1}))/24\"" | at now

