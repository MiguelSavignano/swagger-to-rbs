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
        all_responses_typed: all_responses_typed,
        all_responses_for_return_method: all_responses_for_return_method,
      }
    rescue => e
      raise e, "Context: #{path} #{method} Message: #{e.message}"
    end

    def body?
      HashHelper.present? body
    end

    def to_yaml
      {
        path: path,
        method: method,
        path_parameters: parameters,
        method_name: method_name,
        body: body,
        response: response("200"),
        all_responses: all_responses
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

    def response(http_code)
      schema = resolve_all_of(@props.dig("responses", http_code, "content", "application/json", "schema"))
      schema_to_typed(schema, {})
    end

    def all_responses
      result = @props.dig("responses").keys.reduce({}) do |memo, key|
        memo.merge({ key => response(key) })
      end
    end

    def all_responses_for_return_method
      return '{ "200" => response.body }' if all_responses.empty?

      result = all_responses.keys.map{|key| "\"#{key}\" => response.body" }.join(", ")
      "{ #{result} }"
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
      HashHelper.resolve_special_key(data, "allOf") do |key, value|
        value.reduce(value[0]) do |memo, it|
          memo["properties"] = memo["properties"].merge(it["properties"])
          memo
        end
      end
    end
  end
end
