require 'spec_helper'
require "logstash/filters/dockerMetadata"

describe LogStash::Filters::dockerMetadata do
  describe "Set to Hello World" do
    let(:config) do <<-CONFIG
      filter {
        docker_metadata {
          
        }
      }
    CONFIG
    end

    sample("message" => "some text") do
      expect(subject).to include("message")
      expect(subject['message']).to eq('Hello World')
    end
  end
end
