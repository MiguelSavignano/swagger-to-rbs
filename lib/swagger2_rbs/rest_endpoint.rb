require 'slugify'

module Swagger2Rbs
  class RestEndpoint
    attr_reader :path, :method, :props

    def initialize(path, method, props)
      @path = path
      @method = method
      @props = props
    end

    def to_h
      {
        path: path_with_parameters,
        method: method,
        parameters: parameters,
        parameters_typed: parameters_typed,
        method_name: method_name,
        body: body,
        body_typed: body_typed,
        response_typed: response_typed,
      }
    end

    def method_name
      props["operationId"] || path.slugify.gsub("-", "_")
    end

    def path_with_parameters
      path.gsub("{", '\#{')
    end

    def parameters
      return [] unless props["parameters"]

      props["parameters"].select{|it| it["in"] == "path"}.map{|it| it["name"]}
    end

    def response_typed
      schema = resolve_all_of(@props.dig("responses", "200", "content", "application/json", "schema"))
      schema_to_typed(schema, {})
    end

    def parameters_typed
      return nil if method != "get"
      parameters.map{|it| "String #{it}" }
      .push("?Hash[String, String] params")
      .push("?Hash[untyped, untyped] options")
      .join(", ")
    end

    def body_typed
      return nil if method != "post"

      return "Hash[String, untyped]" unless body
      return "Hash[String, untyped]" if body.empty?

    "{" + body.map{ |k, v| to_typed(k, v) }.join(", ") + "}" + " body, ?Hash[untyped, untyped] options"
    end

    def to_typed(k, v)
      return "#{k}: #{v&.capitalize}" unless v.is_a?(Array) || v.is_a?(Hash)
      return "#{k}: {#{v.map{ |k2, v2| to_typed(k2, v2) }.join(", ")}}" if v.is_a?(Hash)

      if v[0]&.is_a?(Hash)
        "#{k}: Array[{" + v[0].map{ |k, v| "#{k}: #{v&.capitalize}" }.join(", ") + "}]"
      else
        "#{k}: Array[#{v[0]&.capitalize}]"
      end
    end

    def body
      body_schema = resolve_of(props.dig("requestBody", "content", "application/json", "schema"))
      return {} unless body_schema

      schema_to_typed(body_schema)
    end

    def parameters_for_method
      return parameters.push("params = {}").push("options = {}").join(", ") if (method == "get")

      parameters.push("body").push("options = {}").join(", ")
    end

    def schema_to_typed(schema, memo = {})
      return nil unless schema

      schema["properties"]&.reduce(memo)do |memo, (k,v)|
        if v["type"] == "object"
          memo.merge({k => schema_to_typed(v, {})})
        elsif v["type"] == "array"
          if v.dig("items", "type") == "object"
            memo.merge({k => [schema_to_typed(v["items"], {})] })
          else
            memo.merge({k => [v.dig("items", "type")] })
          end
        else
          memo.merge({k => v["type"] })
        end
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
