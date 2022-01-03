require 'json'
require 'erb'
require_relative 'swagger2_rbs/rest_endpoint'

module Swagger2Rbs

  def self.resolve_ref(swagger_spec, key_path)
    data = swagger_spec.dig(*key_path)
    return swagger_spec unless data

    if data["schema"].key?("$ref")
      path = data["schema"]["$ref"]
      schema = swagger_spec.dig(*path.gsub("#/", "").split("/"))
      data["schema"] = schema
    end
    swagger_spec
  end

  def self.walk(original, keys = [], &block)
    original.each do |k, v|
      keys.push(k)
      if v.is_a?(Hash)
        v.each do |k2, v2|
          walk(v2, keys.push(k2), &block)
        end
        keys = [k]
      else
        keys.push("2")
        yield keys.join("."), v
      end
    end
  rescue => e
    binding.pry
  end

  def self.get_em(original, h)
    h.each_with_object([]) do |(k,v),keys|
      keys << k
      if v.is_a? Hash
        if v.key?("$ref")
          puts keys
          # binding.pry
          original[k] = {data: "TODO"}
          # v["$ref"] = "TODOOOO"
        end
        keys.concat(get_em(original, v))
      else
        # puts v
      end
    end
  end

  def self.resolve_all_ref(swagger_spec)
    new_spec = swagger_spec
    swagger_spec["paths"].each do |key, value|
      swagger_spec.dig(*["paths", key]).each do |key2, value2|
        # new_spec = resolve_ref(new_spec, ["paths", key, key2, "requestBody", "content", "application/json"])
      end
    end
    new_spec
  end

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
