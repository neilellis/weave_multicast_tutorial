#!/bin/bash -eu
cd $(dirname $0)
count=1

if !which tugboat &> /dev/null
then
    echo "Please install tugboat first, this just requires '$ gem install tugboat'"
    echo "Full instructions including seting up an API key are here https://github.com/pearkes/tugboat/blob/master/README.md"
    exit -1
fi

echo "** This operation will create 3 small digital ocean images, for which you will be charged, press Ctr-C to abort now **"
echo "Please create an SSH key for your digital ocean account and then enter the numeric value below"
echo "Known keys for your account are listed below"
tugboat  keys
read -p "key> " key

if ! keys | grep "id: ${key}"
then
    echo "Sorry that key was recognized, please make sure it is listed below"
    tugboat keys
fi

echo "Creating ${count} droplets of 512MB memory in LON1"
for i in $(seq 1 ${count})
do
    tugboat create -s 66 -i 6375976 -r 7 -q weave_multicast_demo_${i} -k ${key}
done

echo "Now waiting for them to be active and installing .."
for i in $(seq 1 ${count})
do
    tugboat wait weave_multicast_demo_${1}
    while ! tugboat ssh -c true weave_multicast_demo_${1} &> /dev/null
    do
        echo "Waiting for ssh to be ready"
        sleep 10
    done
    tugboat ssh -c "apt-get -y install git; git clone https://github.com/cazcade/weave_multicast_tutorial.git; cd weave_multicast_tutorial; chmod +x *.sh; ./install.sh ${i}"  weave_multicast_demo_${1} &> /dev/null
done

