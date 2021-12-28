require 'json'
require 'httparty'
require 'yaml'
require 'erb'
require 'dotenv/load'
require_relative './sawagger2_rbs'

def to_underscore(string)
  string.gsub!(/(.)([A-Z])/,'\1_\2')
  string.downcase!
end

name = ARGV[0].dup || 'MyApi'
path = ARGV[1].dup || 'spec/fixtures/swagger.json'

result = Swagger2Rbs.generate(name, path)

File.write("#{to_underscore(name)}.rb", result)
