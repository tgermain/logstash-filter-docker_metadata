#!/bin/bash
PWD=$(pwd)
docker run -ti \
-v $PWD:/tmp/logstash-filter \
-v $PWD/setup.sh:/usr/local/bin/setupPlugin \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
logstash bash