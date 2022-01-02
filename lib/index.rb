require 'pry'
require 'json'
require 'httparty'
require 'yaml'
require 'erb'
require 'dotenv/load'
require_relative './sawagger2_rbs'

def to_underscore(string)
  string.gsub(/(.)([A-Z])/,'\1_\2').downcase
end

name = ARGV[0].dup || 'MyApi'
path = ARGV[1].dup || 'swagger.json'
debug = ARGV[2] == "--debug"

swagger_spec = JSON.parse(File.read(path))

data = Swagger2Rbs.swagger_to_rest_api(swagger_spec)
File.write("data.json", JSON.pretty_generate(data)) if debug

File.write("#{to_underscore(name)}.rb", Swagger2Rbs.generate(name, data.dup))
File.write("#{to_underscore(name)}.rbs", Swagger2Rbs.generate_rbs(name, data.dup))
