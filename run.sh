#!/bin/bash -eu
cd /root

while ! grep -q ^1$ /sys/class/net/ethwe/carrier 2>/dev/null
do
    echo "Waiting for the Weave interface (ethwe)"
    sleep 1
done
ip=$(ip addr show ethwe | grep inet | grep -v inet6 | sed 's/^[ ]*inet //g'| cut -d/ -f 1)

./mcreceive 239.1.2.3 1234

echo "Welcome to the Weave Multicast Chat Demo"
while read -p $1 line
do
    echo "$1> $line" | ./mcsend 239.1.2.3 1234
done
