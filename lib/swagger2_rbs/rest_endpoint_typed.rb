require_relative './rbs_type'
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
      RbsType.new(body).write_types
    end

    def response_typed(http_code)
      RbsType.new(response(http_code), symbolize_keys: false).write_types
    end

    def all_responses_typed
      return '{ "200" => untyped }' unless @props.dig("responses")

      RbsType.new(all_responses, symbolize_keys: false).write_types
    end
  end
end
