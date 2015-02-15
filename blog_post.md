Running Multicast on a Public Cloud
===================================

A little background on [Multicast](http://en.wikipedia.org/wiki/IP_multicast) is worthwhile, before we start.

Multicast allows you to broadcast packets to multiple recipients via a known logical address. The address you are sending packets to is a logical destination and is not tied to any piece of hardware. Any device can then listen to that address and receive messages sent to it.

This is publish/subscribe (or pub/sub) at the IP Layer 3 level, which facilitates amongst other things auto-discovery of service. In fact this is how Apple's 'it just works' networking, [Bonjour](http://www.apple.com/support/bonjour/) works.

But it's not all fruit cake and lollipops I'm afraid, something has to manage those logical addresses, and that would be your routers. Each of which can easily be incorrectly configured and all of which is vulnerable to Denial of Service. It's because of these concerns that multicast has had very patchy adoption.

If you're a Mac user you may have come across these problems yourself for example [Bonjour](http://www.apple.com/support/bonjour/) doesn't work across a partitioned network, i.e. it doesn't "just work". This means that iTunes and other pieces of OS X software don't see each other. This is because something on your network is not forwarding the multicast packets correctly, usually a wireless router.

Okay, so that's the problems. Now for the advantages. If you have a working multicast environment, apps can discover each other and you get [Zero-configuration networking](http://en.wikipedia.org/wiki/Zero-configuration_networking) without the need for setting up single point of failure software to discover your services through. It's a flexible solution that takes the concerns away from the application stack and places it into the network stack where it belongs.

What we need is a flat un-partitioned single tenant network.

The Cloud
---------

As if it wasn't hard enough to run a multicast aware network in the first place, now we're putting all our apps on multi-tenant infrastructure, the cloud. In most cases cloud services simply avoid the hassle and just turn off multicast (with one notable exception [Jelastic](http://jelastic.com/) ).

So we've got this amazing automatic, configuration free, self discovery waiting to rock and roll, but we can't use it!

Docker
------

After the advent of [Docker](https://www.docker.com/) many of us are starting to look at things in a different way. Our apps are now the same as machines thanks to Docker. This means our applications can act like they once did, as the sole piece of software running on a machine. Which has the interesting side effect of making older and low level technologies directly relevant to application development and operations.

Forget your [UDDI](http://en.wikipedia.org/wiki/Universal_Description_Discovery_and_Integration), you can go back to using DNS (optionally with SRV records) instead. Forget application servers, just load balance your containers. It is as if we have turned back the clock 30 years, **in a good way**.

And in this new world order of [Docker](https://www.docker.com/), distributed service discovery can now be done simply with multicast.

Weave
-----

So what we really need to make all this work is a way to overlay the existing network in such a way as to get a single tenant unpartioned, flat network. This is where [Weave](https://github.com/zettio/weave) now comes in. [Weave](https://github.com/zettio/weave) provides an overlay network which links [Docker](https://www.docker.com/) containers together and allows any Layer 2 protocol over it, including multicast!

Let's Get Down to it Boppers
============================

To get the most out of learning about multicast and weave you should really get a [Digital Ocean Account](https://www.digitalocean.com/?refcode=7b4639fc8194) ($10 off with that link) - that way you can run a single script to get the demo running. The full tutorial can be found on [Github](https://github.com/cazcade/weave_multicast_tutorial) including a single script deployment. But for this blog post we're going to go through the steps one at a time.

Show me the code!
-----------------

You've waited patiently so here we go, let's install weave on each of our machines:

    sudo wget -O /usr/local/bin/weave \
      https://raw.githubusercontent.com/zettio/weave/master/weaver/weave
    sudo chmod a+x /usr/local/bin/weave

Next install ethtool and conntrack on them, if you're on a Debian system such as Ubuntu, this will work:

    apt-get -y install ethtool conntrack

Now we need to start up [Weave](https://github.com/zettio/weave) using a private network address. On the first host enter:

    weave launch "10.0.0.101/24"

This says that the host we're on now will have an ip address of 10.0.0.101 assigned to it on the [Weave](https://github.com/zettio/weave) network and we're interested in other ip addresses in the range 10.0.0.0-10.0.0.255.

On the second host set the variable `seed_host` to be equal to the external IP address of the first host. Then run

    weave launch "10.0.0.102/24" ${seed_host}

We have set up two hosts that can see each other so let's check what's happening, on either host enter:

    weave status

If all is okay we can now start our [Docker](https://www.docker.com/) container on the first host:

    CONTAINER=$(weave run 10.0.0.101/24 -t -i neilellis/weave-multicast-tutorial /run.sh Mal) docker attach $CONTAINER

And the second host:

    CONTAINER=$(weave run 10.0.0.102/24 -t -i neilellis/weave-multicast-tutorial /run.sh Jayne)  docker attach $CONTAINER

That's it, you should now have a working chat system using multicast to connect your machines across a public cloud network, all thanks to [Weave](https://github.com/zettio/weave)!

If you're lazy (like me) and just want to see it working, then go and get your [Digital Ocean Account](https://www.digitalocean.com/?refcode=7b4639fc8194), set up [Tugboat](https://github.com/pearkes/tugboat) on your machine then just:

    git clone https://github.com/neilellis/weave_multicast_tutorial.git
    cd weave_multicast_tutorial
    ./create_digital_ocean_example.sh

When you're finished remove the droplets with:

    ./cleanup.sh

Obviously creating droplets will incur charges.

All the best

Neil Ellis

- E: hello@ **neilellis.me**
- W: http://neilellis.me
- T: http://twitter.com/neilellis

*The example C code used in the [Docker](https://www.docker.com/) example comes from http://www.nmsl.cs.ucsb.edu/MulticastSocketsBook/*
