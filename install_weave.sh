#!/bin/bash -eu
sudo wget -q -O /usr/local/bin/weave \
  https://raw.githubusercontent.com/zettio/weave/master/weaver/weave
sudo chmod a+x /usr/local/bin/weave
apt-get -y -q install ethtool conntrack

