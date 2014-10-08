#!/bin/bash -eu
cd $(dirname $0)
count=2
#size=66
size=62

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
read -p "numeric key id> " key

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
    tugboat create -s ${size} -i 6375976 -r 7 weave-multicast-demo-${i} -k ${key}
done

echo "Now waiting for it to be active and installed"
for i in $(seq 1 ${count})
do
    tugboat wait weave-multicast-demo-${i}
    sleep 10
    while ! tugboat ssh -c true weave-multicast-demo-${i} &> /dev/null
    do
        echo "Waiting for ssh to be ready"
        sleep 10
    done
    sleep 20
    ips=$(tugboat droplets | grep ^weave-multicast-demo- | cut -d: -f2 | cut -d, -f1 | tr -d ' ')
    tugboat ssh -c "apt-get -y -q install git; git clone https://github.com/cazcade/weave_multicast_tutorial.git; cd weave_multicast_tutorial; chmod +x *.sh; ./install.sh ${i}"  weave-multicast-demo-${i}
    sleep 20
    tugboat ssh -c " cd weave_multicast_tutorial; ./run_demo.sh ${i} ${ips}"  weave-multicast-demo-${i}
done

echo
echo
echo "  ******************************************************"
echo "  * Now  do the following in seperate terminal windows *"
echo "  ******************************************************"
echo
echo
for id in $(tugboat droplets | grep ^weave-multicast-demo- | cut -d: -f5 | tr -d ' ' | tr -d ')')
do
    echo "tugboat ssh -c \"docker attach \\\$(< ~/.container_id)\" -i ${id}"
done

echo "And when you're finished, just run $(pwd)/cleanup.sh"

