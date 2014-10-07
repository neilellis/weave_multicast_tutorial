#!/bin/bash -eu
sudo wget -O /usr/local/bin/weave \
  https://raw.githubusercontent.com/zettio/weave/master/weaver/weave
sudo chmod a+x /usr/local/bin/weave
apt-get -y install ethtool conntrack

