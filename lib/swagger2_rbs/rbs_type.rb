module Swagger2Rbs
  class RbsType
    attr_reader :data, :symbolize_keys
    def initialize(data, symbolize_keys: true)
      @data = data
      @symbolize_keys = symbolize_keys
    end

    def write_types
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

    def key_to_typed(k)
      return "#{k}:" if @symbolize_keys
      "\"#{k}\" =>"
    end

    def to_typed(k, v)
      return "#{key_to_typed(k)} #{type_case(v)}" unless v.is_a?(Array) || v.is_a?(Hash)
      return "#{key_to_typed(k)} {#{v.map{ |k2, v2| to_typed(k2, v2) }.join(", ")}}" if v.is_a?(Hash)

      if v[0]&.is_a?(Hash)
        "#{key_to_typed(k)} Array[{" + v[0].map{ |k, v| to_typed(k, v) }.join(", ") + "}]"
      else
        "#{key_to_typed(k)} Array[#{type_case(v[0])}]"
      end
    end
  end
end
