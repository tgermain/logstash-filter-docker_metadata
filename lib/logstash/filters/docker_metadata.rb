# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'docker'
require 'json'
require 'lru_redux'
# This example filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::DockerMetadata < LogStash::Filters::Base

  # Setting the config_name here is required.
  config_name "docker_metadata"
  

  config :docker_url,
    :validate => :string,
    :default => 'unix:///var/run/docker.sock',
    :required => false,
    :deprecated => false

  config :cache_size,
    :validate => :number,
    :default => 100,
    :required => false,
    :deprecated => false

  config :container_id_regexp,
    :validate => :string,
    :default => '(\w{64})',
    :required => false,
    :deprecated => false
  
  def get_metadata(container_id)
    begin
      Docker::Container.get(container_id).info
    rescue Docker::Error::NotFoundError
      nil
    end
  end

  # convert array of "key=value" string into a hash of "key": value
  def format_env(env_array)
    res= Hash.new
    env_array.each do |env_line|
      env_key, env_value = env_line.split("=",2)
      res[env_key]=env_value

    end
    return res
  end

  public
  def register
    # Add instance variables 
    Docker.url = @docker_url

    @cache = LruRedux::ThreadSafeCache.new(@cache_size)
    @container_id_regexp_compiled = Regexp.compile(@container_id_regexp)
  end # def register

  public
  def filter(event)

    # get container id from path field
    if event["path"]
      container_id = event["path"].match(@container_id_regexp_compiled)
    end

    # if it failed fall back to message field
    if !container_id || !container_id[0]
      if event["message"]
        container_id = event["message"].match(@container_id_regexp_compiled)
      end
    end

    if container_id && container_id[0]
      container_id = container_id[0]
      # try the cache else call the docker API
      metadata = @cache.getset(container_id[0]){self.get_metadata(container_id)}
    end

    if metadata
      # add a docker field with all informations
      event["docker"] = {

        :id                 => metadata['id'],
        :name               => metadata['Name'],
        :container_hostname => metadata['Config']['Hostname'],
        :image              => metadata['Config']['Image'],
        :image_id           => metadata['Image'],
        :labels             => metadata['Config']['Labels'],
        :env                => self.format_env(metadata['Config']['Env'])
      }
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::DockerMetadata
