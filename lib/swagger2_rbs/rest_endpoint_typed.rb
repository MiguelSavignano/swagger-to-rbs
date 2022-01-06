module Swagger2Rbs

  module RestEndpointTyped
    def response_typed
      schema = resolve_all_of(@props.dig("responses", "200", "content", "application/json", "schema"))
      schema_to_typed(schema, {})
    end

    def typed_parameters
      options_typed = "?Hash[untyped, untyped] options"
      return "(#{options_typed})" unless body && parameters
      return "(#{options_typed})" if body.empty? && parameters.empty?

      typed_parameters = parameters&.map{|it| "String #{it}" } || []

      typed = (body.is_a?(Array) ? body[0] : body)&.map{ |k, v| to_typed(k, v) }
      result = if body.is_a?(Array)
        typed_parameters.push("Array[{#{typed}}] body")
      elsif !typed.empty?
        typed_parameters.push("#{typed}} body")
      else
        typed_parameters
      end

      "(#{result.push(options_typed).join(', ')})"
    end

    def parameters_typed
      return nil unless parameters
      return nil if parameters&.empty?

      result = parameters&.map{|it| "String #{it}" }
      &.push("?Hash[untyped, untyped] options")
      &.join(", ")

      "(#{result})"
    end

    def body_typed
      return nil if method == "get"

      options_typed = "?Hash[untyped, untyped] options"
      return "(#{options_typed})" unless body
      return "(#{options_typed})" if body.empty?

      typed = (body.is_a?(Array) ? body[0] : body)&.map{ |k, v| to_typed(k, v) }.join(", ")
      if body.is_a?(Array)
        "(Array[{#{typed}}] body, #{options_typed})"
      else
        "({#{typed}} body, #{options_typed})"
      end
    end

    def type_case(str)
      case str
      when "boolean"
        "bool"
      else
        str&.capitalize
      end
    end

    def to_typed(k, v)
      return "#{k}: #{type_case(v)}" unless v.is_a?(Array) || v.is_a?(Hash)
      return "#{k}: {#{v.map{ |k2, v2| to_typed(k2, v2) }.join(", ")}}" if v.is_a?(Hash)

      if v[0]&.is_a?(Hash)
        "#{k}: Array[{" + v[0].map{ |k, v| to_typed(k, v) }.join(", ") + "}]"
      else
        "#{k}: Array[#{type_case(v[0])}]"
      end
    end

    def schema_to_typed(schema, memo = {})
      return nil unless schema

      properties = if schema["type"]["array"]
        schema["items"]["properties"]
      else
        schema["properties"]
      end

    result = properties&.reduce(memo)do |memo, (k,v)|
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
      return [result] if schema["type"]["array"]

      result
    end
  end
end
