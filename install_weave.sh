#!/bin/bash -eu
sudo wget -q -O /usr/local/bin/weave https://raw.githubusercontent.com/zettio/weave/master/weaver/weave
sudo chmod a+x /usr/local/bin/weave
apt-get -y -qq install ethtool conntrack
sudo wget -q -O /usr/local/bin/docker-ns  https://raw.githubusercontent.com/zettio/weave/master/weaver/docker-ns
sudo chmod +x /usr/local/bin/docker-ns

