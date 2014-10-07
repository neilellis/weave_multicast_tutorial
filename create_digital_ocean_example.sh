#!/bin/bash -eux
cd $(dirname $0)
count=1

if !which tugboat &> /dev/null
then
    echo "Please install tugboat first, this just requires '$ gem install tugboat'"
    echo "Full instructions including seting up an API key are here https://github.com/pearkes/tugboat/blob/master/README.md"
    exit -1
fi

echo "** This operation will destroy any droplets with the name containing 'weave-multicast-demo-' and will then create 3 small Digital OCean images with that name. You will be charged by Digital Ocean for this, press Ctr-C to abort now **"
echo "Please create an SSH key for your Digital Ocean account and then enter the numeric value"
echo "(Known keys for your account are listed below)"
tugboat  keys
read -p "key> " key

if ! tugboat keys | grep "id: ${key}"
then
    echo "Sorry that key was not recognized, please make sure it is listed below:"
    tugboat keys
    exit -1
fi

destroyed=false
for id in $(tugboat droplets | grep ^weave-multicast-demo- | cut -d: -f5 | tr -d ' ' | tr -d ')')
do
    tugboat destroy -i $id || ( echo "Failed to destroy existing machine, please run $(pwd)/cleanup.sh" && exit -1)
    destroyed=true
done

( ${destroyed} && sleep 30 ) || :

echo "Creating ${count} droplets of 512MB memory in LON1"
for i in $(seq 1 ${count})
do
    tugboat create -s 66 -i 6375976 -r 7 weave-multicast-demo-${i} -k ${key}
done

echo "Now waiting for them to be active and installing .."
for i in $(seq 1 ${count})
do
    tugboat wait weave-multicast-demo-${i}
    while ! tugboat ssh -c true weave-multicast-demo-${i} &> /dev/null
    do
        echo "Waiting for ssh to be ready"
        sleep 10
    done
    ips=$(tugboat droplets | grep ^weave-multicast-demo- | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
    tugboat ssh -c "apt-get -y install git; git clone https://github.com/cazcade/weave_multicast_tutorial.git; cd weave_multicast_tutorial; chmod +x *.sh; ./install.sh ${i} ${ips}"  weave-multicast-demo-${i}
done


echo "Now create seperate sessions and do the following in seperate terminal windows:"

for id in $(tugboat droplets | grep ^weave-multicast-demo- | cut -d: -f5 | tr -d ' ' | tr -d ')')
do
    echo "tugboat ssh -c \"docker attach $(< ~/.container_id)\" -i ${id}"
done

echo "And when you're finished, just run $(pwd)/cleanup.sh"

