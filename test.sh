docker run -ti \
-v /home/germaint/dev/logstash-filter-docker-metadata:/tmp/logstash-filter \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
logstash bash