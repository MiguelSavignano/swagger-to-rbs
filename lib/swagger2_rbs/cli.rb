require 'thor'
require 'json'
require 'yaml'

module Swagger2Rbs
  class Cli < Thor
    attr_reader :name, :swagger_path, :rest_api_path, :debug

    desc 'genearte', 'generate http client and rbs'
    option :name, desc: 'Name'
    option :spec, desc: 'Swagger file path'
    option :debug, desc: 'Generate debug file'
    def generate
      @name = options[:name]
      @swagger_path = options[:spec]
      @debug = options[:debug]
      data = fetch_data
      File.write(".rest-api.json", JSON.pretty_generate(data)) if debug

      file_name = to_underscore(name)
      File.write("#{file_name}.rb", ::Swagger2Rbs.generate(name, data.dup))
      File.write("#{file_name}.rbs", ::Swagger2Rbs.generate_rbs(name, data.dup))
    end

    desc 'genearte-yaml', 'generate yaml file'
    option :name, desc: 'Name'
    option :spec, desc: 'Swagger file path'
    def generate_yaml
      @name = options[:name]
      @swagger_path = options[:spec]
      @debug = options[:debug]
      swagger_spec = JSON.parse(File.read(@swagger_path))

      file_name = to_underscore(name)
      File.write("#{file_name}.yaml", ::Swagger2Rbs.swagger_to_rest_api_yaml(swagger_spec))
    end

    private
    def fetch_data
      if swagger_path
        swagger_spec = JSON.parse(File.read(swagger_path))
        ::Swagger2Rbs.swagger_to_rest_api(swagger_spec)
      elsif rest_api_path
        data = YAML.load_file(rest_api_path, symbolize_names: true)
        ::Swagger2Rbs.rest_api_all(data)
      else
        raise StandardError, "Missing swagger_path or rest_api_path"
      end
    end

    def to_underscore(string)
      string.gsub(/(.)([A-Z])/,'\1_\2').downcase
    end
  end
end
