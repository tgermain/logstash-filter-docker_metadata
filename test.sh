#!/bin/bash
PWD=$(pwd)
docker run -ti -v $PWD:/tmp/logstash-filter -v /var/run/docker.sock:/var/run/docker.sock:ro logstash bash