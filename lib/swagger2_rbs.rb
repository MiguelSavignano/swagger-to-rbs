require 'json'
require 'erb'
require_relative 'swagger2_rbs/rest_endpoint'

module Swagger2Rbs

  def self.swagger_to_rest_api(swagger_spec)
    result = []
    swagger_spec["paths"].each do |path, data|
      data.each do |method, props|
        rest_data = RestEndpoint.new(path, method, props)
        result << rest_data.to_h
      end
    end

    { base_uri: swagger_spec["servers"].first["url"], endpoints: result }
  end

  def self.rest_api_all(spec)
    result = []
    spec[:endpoints].each do |endpoint|
      rest_data = RestEndpoint.new(endpoint[:path], endpoint[:method], endpoint[:props])
      result << rest_data.to_h
    end

    { base_uri: spec[:base_uri], endpoints: result }
  end

  def self.mock_rest_api_data
    data = YAML.load_file('spec/fixtures/rest-api.yaml').transform_keys(&:to_sym)
    data[:endpoints].map!{|it| it.transform_keys(&:to_sym) }
    data
  end

  def self.generate(name, data)
    @module_name = name
    @data = data
    template = File.read("#{File.dirname(__dir__ )}/lib/templates/http_client.rb.erb")

    ERB.new(template, nil, '-').result(binding)
  end

  def self.generate_rbs(name, data)
    @module_name = name
    @data = data
    template = File.read("#{File.dirname(__dir__ )}/lib/templates/http_client.rbs.erb")

    ERB.new(template, nil, '-').result(binding)
  end
end