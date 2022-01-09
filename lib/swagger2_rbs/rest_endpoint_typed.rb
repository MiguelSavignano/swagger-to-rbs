module Swagger2Rbs

  module RestEndpointTyped
    def typed_parameters_for_method
      options_typed = "?Hash[untyped, untyped] options"
      return "(#{options_typed})" unless body && parameters
      return "(#{options_typed})" if body.empty? && parameters.empty?

      typed_parameters = parameters&.map{|it| "String #{it}" } || []

      typed_parameters.push("#{body_typed} body") if body?

      "(#{typed_parameters.push(options_typed).join(', ')})"
    end

    def body_typed
      write_types(body)
    end

    def response_typed(http_code)
      write_types(response(http_code))
    end

    def all_responses_typed
      return '{ "200" => untyped }' unless @props.dig("responses")

      write_types(all_responses)
    end

    def write_types(data)
      return nil unless HashHelper.present? data
      typed = (data.is_a?(Array) ? data[0] : data)&.map{ |k, v| to_typed(k, v) }.join(', ')
      if data.is_a?(Array)
        "Array[{ #{typed} }]"
      else
        "{ #{typed} }"
      end
    end

    def type_case(str)
      case str
      when "boolean"
        "bool"
      when nil
        "untyped"
      else
        str&.capitalize
      end
    end

    def to_typed(k, v)
      return "\"#{k}\" => #{type_case(v)}" unless v.is_a?(Array) || v.is_a?(Hash)
      return "\"#{k}\" => {#{v.map{ |k2, v2| to_typed(k2, v2) }.join(", ")}}" if v.is_a?(Hash)

      if v[0]&.is_a?(Hash)
        "\"#{k}\" => Array[{" + v[0].map{ |k, v| to_typed(k, v) }.join(", ") + "}]"
      else
        "\"#{k}\" => Array[#{type_case(v[0])}]"
      end
    end

    def schema_to_typed(schema, memo = {})
      return nil unless schema

      properties = schema["type"] == "array" ? schema["items"]["properties"] : schema["properties"]

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
      return [result] if schema["type"] == "array"

      result
    end
  end
end
