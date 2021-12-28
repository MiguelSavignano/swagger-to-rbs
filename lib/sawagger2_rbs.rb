require 'json'
require 'httparty'
require 'erb'
require 'slugify'

module Swagger2Rbs

  def self.to_method_name(string)
    string.slugify.gsub("-", "_")
  end

  def self.swagger_to_rest_api(file_path)
    swagger_spec = JSON.parse(File.read(file_path))

    result = []
    swagger_spec["paths"].each do |path, data|
      data.each do |method, props|
        parameters = props["parameters"] && props["parameters"].select{|it| it["in"] == "path"}.map{|it| it["name"]}
        result << {
          path: path,
          method: method,
          parameters: parameters,
          method_name: props["operationId"] || to_method_name(path),
        }
      end
    end

    { base_uri: swagger_spec["servers"].first["url"], endpoints: result }
  end

  def self.template
    <<-EOF
require 'httparty'

class <%= @module_name %>
  include HTTParty
  base_uri "<%= @data[:base_uri] %>"
  <%- @data[:endpoints].each do |endpoint| -%>
  <%- parameters = endpoint[:parameters] || [] -%>
  <%- path = endpoint[:path].gsub("{", '\#{') -%>

  <%- if endpoint[:method] == 'get' -%>
  def <%= endpoint[:method_name] %>(<%= parameters.push("params").join(", ") %>, options = {})
    self.class.<%= endpoint[:method] %>("<%= path %>", params: params.to_json, headers: { 'Content-Type' => 'application/json' }.merge(options))
  end
  <%- else -%>
  def <%= endpoint[:method_name] %>(<%= parameters.push("body").join(", ") %>, options = {})
    self.class.<%= endpoint[:method] %>("<%= path %>", body: body.to_json, headers: { 'Content-Type' => 'application/json' }.merge(options))
  end
  <%- end -%>
  <%- end -%>
end
EOF
  end

  def self.generate(name, swagger_path)
    @module_name = name
    @data = swagger_to_rest_api(swagger_path)

    ERB.new(template, nil, '-').result(binding)
  end
end


