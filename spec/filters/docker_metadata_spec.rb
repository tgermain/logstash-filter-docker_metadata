require_relative "../spec_helper"
require "logstash/filters/docker_metadata"

describe LogStash::Filters::DockerMetadata do

  let(:container_info) do
    metadata = {}
    metadata['id'] = "123456789"
    metadata['Name'] = "container"
    metadata['Image'] = "image_id"
    metadata['Config'] = {}
    metadata['Config']['Hostname'] = "hostname"
    metadata['Config']['Image'] = "image"
    metadata['Config']['Labels'] = { "label1" => "label_value"}
    metadata['Config']['Env'] = [
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      "NGINX_VERSION=1.9.5-1~jessie"
    ]
    metadata
  end


  describe "Docker container metadada as symbol keys in hash by default" do
    let(:config) do <<-CONFIG
      filter {
        docker_metadata {

        }
      }
    CONFIG
    end

    sample("path" => "/var/lib/docker/containers/d58155b6b2979776ef3594838536375ec19c6452431888f1d71bb7b2d5b8d84b/d58155b6b2979776ef3594838536375ec19c6452431888f1d71bb7b2d5b8d84b-json.log") do
      c = double()
      expect(Docker::Container).to receive(:get).with('d58155b6b2979776ef3594838536375ec19c6452431888f1d71bb7b2d5b8d84b').and_return(c)
      expect(c).to receive(:info).and_return(container_info)

      expect(subject['docker']).not_to be_nil
      expect(subject['docker']['name']).to eq('container')
      expect(subject['docker']['name']).to eq(subject['docker'][:name])
      expect(subject['docker']['env']['NGINX_VERSION']).to eq('1.9.5-1~jessie')
    end
  end
end
