#!/bin/sh

if [ "x${1}" = "x" ]; then
    CLIENT_DEVICE=enp0s31f6 #eth0
else
    CLIENT_DEVICE=${1}
fi

if [ "x${2}" = "x" ]; then
    SERVER_DEVICE=wlp2s0 #wlan0
else
    SERVER_DEVICE=${2}
fi

if [ "x${3}" = "x" ]; then
    IP=192.168.123.100
else
    IP=${3}
fi

sudo ip addr add ${IP}/24 dev ${CLIENT_DEVICE}
sudo ip link set up dev ${CLIENT_DEVICE}

sudo sysctl net.ipv4.ip_forward=1

sudo iptables -t nat -A POSTROUTING -o ${SERVER_DEVICE} -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i ${CLIENT_DEVICE} -o ${SERVER_DEVICE} -j ACCEPT
