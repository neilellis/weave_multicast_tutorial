#!/bin/bash -eu
./install_weave.sh
echo $1 > ~/.weave_host_id
docker built -t weave-multicast-tutorial .
./run_weave.sh