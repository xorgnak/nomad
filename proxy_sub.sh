#!/bin/bash

while read -u 10 m
do
    a=($m);
    topic=${a[0]};
    a=("${a[@]:1}");
    payload="${a[@]}";
    echo "MQTT: $topic: $payload";
    if [[ "$topic" == "CAMS" ]]; then
	## add proxy.
	## redis-cli hset CAMS 
    fi
done 10< <(mosquitto_sub -h vango.me -t '#' -v)
