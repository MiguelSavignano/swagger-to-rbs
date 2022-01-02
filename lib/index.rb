require 'pry'
require 'json'
require 'httparty'
require 'yaml'
require 'erb'
require 'dotenv/load'
require_relative './sawagger2_rbs'

class Swagger2RbsCli
  attr_reader :name, :swagger_path, :rest_api_path, :debug

  def initialize(name: "MyApi", swagger_path: nil, rest_api_path: nil, debug: false)
    @name = name
    @swagger_path = swagger_path
    @rest_api_path = rest_api_path
    @debug = debug
  end

  def run
    data = fetch_data
    File.write(".rest-api.json", JSON.pretty_generate(data)) if debug

    file_name = to_underscore(name)
    File.write("#{file_name}.rb", Swagger2Rbs.generate(name, data.dup))
    File.write("#{file_name}.rbs", Swagger2Rbs.generate_rbs(name, data.dup))
  end

  def fetch_data
    if swagger_path
      swagger_spec = JSON.parse(File.read(swagger_path))
      Swagger2Rbs.swagger_to_rest_api(swagger_spec)
    elsif rest_api_path
      data = YAML.load_file(rest_api_path, symbolize_names: true)
      Swagger2Rbs.rest_api_all(data)
    else
      raise StandardError, "Missing swagger_path or rest_api_path"
    end
  end

  def to_underscore(string)
    string.gsub(/(.)([A-Z])/,'\1_\2').downcase
  end
end

Swagger2RbsCli.new(name: "MyApi", rest_api_path: 'rest-api.yaml', debug: true).run
# Swagger2RbsCli.new(name: "MyApi", swagger_path: 'swagger.json', debug: true).run
