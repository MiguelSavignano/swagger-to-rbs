require 'slugify'
require_relative 'rest_endpoint_typed'

module Swagger2Rbs
  class RestEndpoint
    attr_reader :path, :method, :props
    include RestEndpointTyped

    def initialize(path, method, props)
      @path = path
      @method = method
      @props = props || {}
    end

    def to_h
      {
        path: path_with_parameters,
        http_method: method,
        parameters_for_method: parameters_for_method,
        typed_parameters_for_method: typed_parameters_for_method,
        has_body: body?,
        method_name: method_name,
        response_typed: response_typed,
      }
    rescue => e
      raise e, "Context: #{path} #{method} Message: #{e.message}"
    end

    def body?
      body && !body.empty?
    end

    def to_yaml
      {
        path: path,
        method: method,
        path_parameters: parameters,
        method_name: method_name,
        body: body,
        response: response_typed,
      }
    rescue => e
      raise e, "Context: #{path} #{method} Message: #{e.message}"
    end

    def method_name
      props["operationId"] || path.slugify.gsub("-", "_")
    end

    def path_with_parameters
      path.gsub("{", '#{')
    end

    def parameters
      return [] unless props["parameters"]

      props["parameters"]&.select{|it| it["in"] == "path"}&.map{|it| it["name"]}
    end

    def body
      body_schema = resolve_of(props.dig("requestBody", "content", "application/json", "schema"))
      return {} unless body_schema

      schema_to_typed(body_schema)
    end

    def parameters_for_method
      return parameters.push("options = {}").join(", ") if method == "get"

      if body&.empty?
        parameters.push("options = {}").join(", ")
      else
        parameters.push("body").push("options = {}").join(", ")
      end
    end

    def resolve_of(data)
      resolve_all_of(resolve_one_of(data))
    end

    def resolve_one_of(data)
      return data unless data
      return data unless data["oneOf"]

      data["oneOf"].reduce(&:merge)
    end

    def resolve_all_of(data)
      return data unless data
      return data unless data["allOf"]

      data["allOf"].reduce(&:merge)
    end
  end
end
