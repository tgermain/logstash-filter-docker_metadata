[![Gem Version](https://badge.fury.io/rb/logstash-filter-docker_metadata.svg)](http://badge.fury.io/rb/logstash-filter-docker_metadata)

# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

This filter add docker metadata to messages that contain a docker ID. It's heavily inspired from [fluent-plugin-docker_metadata_filter](https://github.com/fabric8io/fluent-plugin-docker_metadata_filter).

This plugin use the Docker socket to call Docker API, therefore it needs the docker socket to be mounted (at least in read-only mode) inside the container. 
Example : 
```
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock:ro logstash 
```  

At this point, It add to the event :
- name of the container
- complete id of the container
- image used
- labels
- environment variables injected inside the container

But everything accessible from the docker API (or via `docker inspect `) can be exported.

## Usage 

Configuration used : `logstash agent -e "filter { docker_metadata{} }"`

Another container is running with `-e jesuis=goleri` with ID `68073a44cdde2d2a14a91e06a036c9c03f8c3122deb47e44c908f5fb6391394e` .

Input :
```json
ConfPath": "/var/lib/docker/containers/68073a44cdde2d2a14a91e06a036c9c03f8c3122deb47e44c908f5fb6391394e/resolv.conf",
```

Logstash output :
```
{
       "message" => "ConfPath\": \"/var/lib/docker/containers/68073a44cdde2d2a14a91e06a036c9c03f8c3122deb47e44c908f5fb6391394e/resolv.conf\",",
      "@version" => "1",
    "@timestamp" => "2015-08-04T14:49:51.807Z",
          "type" => "stdin",
          "host" => "4187a88a77cf",
        "docker" => {
                        :id => "68073a44cdde2d2a14a91e06a036c9c03f8c3122deb47e44c908f5fb6391394e",
                      :name => "/serene_wilson",
        :container_hostname => "68073a44cdde",
                     :image => "kk_centos",
                  :image_id => "c0050e8a70ae96325986222df1ce0b81e9170a01442173de39c6b622eb0bda22",
                    :labels => {},
                       :env => {
            "jesuis" => "goleri",
              "PATH" => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        }
    }
}
```
## Filter parameters

| name                  | default value                 | comment |
| :-------------         | :-------------                 | :------------- |
| `docker_url`          | `unix:///var/run/docker.sock` | make sure it match where you mount the docker socket |
| `container_id_regexp` | `(\w{64})`                    | match the complete Id of a docker container |
| `cache_size`          | 100                           |  |



## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Install dependencies
```sh
bundle install
```

#### Test
There is no unit tests. 
TODO : write unit tests

#### Build gem
```sh
gem build logstash-filter-docker_metadata.gemspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash Docker container
There is a script which launch a docker container using the latest logstash image and mount this directory into the container at `/tmp/logstash-filter/`

- Build the gem outside of the container
```sh
gem build logstash-filter-docker_metadata.gemspec
```

- start the docker container
```sh
./dockerTest.sh
```

- Install plugin
```sh
plugin install /tmp/logstash-filter/logstash-filter-docker_metadata-0.1.0.gem
```
- Run Logstash with your plugin
```sh
logstash agent -e "filter { docker_metadata{} }"
```

The 2 last steps can be done in one command using `setupPlugin` command.


At this point any modifications to the plugin code will not be applied to this local Logstash setup.
After modifying the plugin, rebuild the gem and reinstalle it inside the docker container.



## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elasticsearch/logstash/blob/master/CONTRIBUTING.md) file.

## Licence
It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.
