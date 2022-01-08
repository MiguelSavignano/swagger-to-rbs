require 'json'
require 'erb'
require_relative 'swagger2_rbs/rest_endpoint'
require_relative 'swagger2_rbs/hash_helper'

module Swagger2Rbs

  def self.resolve_all_ref(swagger_spec)
    HashHelper.resolve_special_key(swagger_spec, "$ref") do |key, value|
      ref_key = value.gsub("#/", "").split("/")
      swagger_spec.dig(*ref_key)
    end
  end

  def self.swagger_to_rest_api(swagger_spec, parse_method = :to_h)
    result = []
    resolve_all_ref(swagger_spec)["paths"].each do |path, data|
      data.each do |method, props|
        rest_data = RestEndpoint.new(path, method, props)
        result << rest_data.send(parse_method)
      end
    end

    { base_uri: swagger_spec["servers"].first["url"], endpoints: result }
  end

  def self.swagger_to_rest_api_yaml(swagger_spec)
    response = swagger_to_rest_api(swagger_spec, :to_yaml)
    YAML.dump(
      HashHelper.deep_transform_keys_in_object!(response, &:to_s)
    ).gsub("---\n", "")
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
