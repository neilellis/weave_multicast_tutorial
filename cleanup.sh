#!/bin/bash -eu

for id in $(tugboat droplets | grep ^weave-multicast-demo- | cut -d: -f5 | tr -d ' ' | tr -d ')')
do
    tugboat destroy -i $id
done
