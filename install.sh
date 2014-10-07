#!/bin/bash -eu
./install_weave.sh
echo $1 > ~/.weave_host_id
shift
./run_weave.sh $@