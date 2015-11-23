# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'docker'
require 'json'
require 'lru_redux'

require_relative 'docker_hash'
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

  config :field_docker_id,
    :validate => :string,
    :default => 'path',
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
    # get container id from @field_docker_id field
    if event[@field_docker_id]
      container_id = event[@field_docker_id].match(@container_id_regexp_compiled)
    end

    if container_id && container_id[0]
      container_id = container_id[0]
      # try the cache else call the docker API
      metadata = @cache.getset(container_id[0]){self.get_metadata(container_id)}
    end

    if metadata
      # add a docker field with all informations
      # Added as custom hash so we get easy IndifferentAccess as symbol keys
      # proved pretty hard to work with in logstash config
      event["docker"] = DockerHash.new
      event["docker"][:id]                  = metadata['id']
      event["docker"][:name]                = metadata['Name']
      event["docker"][:container_hostname]  = metadata['Config']['Hostname'],
      event["docker"][:image]               = metadata['Config']['Image'],
      event["docker"][:image_id]            = metadata['Image'],
      event["docker"][:labels]              = metadata['Config']['Labels'],
      event["docker"][:env]                 = self.format_env(metadata['Config']['Env'])

    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::DockerMetadata
