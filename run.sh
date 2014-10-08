#!/bin/bash -eu
cd /root

while ! grep -q ^1$ /sys/class/net/ethwe/carrier 2>/dev/null
do
    echo "Waiting for the Weave interface (ethwe)"
    sleep 1
done
ip=$(ip addr show ethwe | grep inet | grep -v inet6 | sed 's/^[ ]*inet //g'| cut -d/ -f 1)

echo "Welcome to the Weave Multicast Chat Demo"
echo

(/mcreceive 239.1.2.3 1234  | sed "s/^Received [0-9]* bytes from //g") &

while read -p "${1}> " line
do
    echo "$line"
done | /mcsend 239.1.2.3 1234


