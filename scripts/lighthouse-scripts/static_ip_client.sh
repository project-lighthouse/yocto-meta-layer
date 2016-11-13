#!/bin/sh

if [ "x${1}" = "x" ]; then
    IP=192.168.123.201
else
    IP=${1}
fi

if [ "x${2}" = "x" ]; then
    ROUTE=192.168.123.100
else
    ROUTE=${2}
fi

ip addr add ${IP}/24 dev eth0
ip link set up dev eth0
ip route add default via ${ROUTE} dev eth0