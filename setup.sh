#!/bin/bash
plugin install /tmp/logstash-filter/logstash-filter-docker_metadata-0.1.0.gem
logstash agent -e "filter { docker_metadata{} }"