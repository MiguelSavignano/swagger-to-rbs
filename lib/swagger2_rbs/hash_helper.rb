module Swagger2Rbs
  class HashHelper

    def self.resolve_special_key(data, special_key)
      return data unless data

      new_data = data.dup
      walk(data) do |key, value|
        if (key.split(".").last == special_key)
          update_key = key.split(".").reject{|k| k == special_key}.join(".")
          new_value = yield(key, value)
          set_value(new_data, update_key, new_value)
        end
      end
      new_data
    end

    def self.present?(hash)
      hash && !hash.empty?
    end

    # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/hash/keys.rb#L129
    def self.deep_transform_keys_in_object!(object, &block)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = deep_transform_keys_in_object!(value, &block)
        end
        object
      when Array
        object.map! { |e| deep_transform_keys_in_object!(e, &block) }
      else
        object
      end
    end

    def self.set_value(hash, key, value)
      arr = key.split(".")
      last_key = arr.pop()
      hash.dig(*arr)[last_key] = value
      hash
    rescue => e
      hash
    end

    def self.walk(hash, &block)
      hash.each do |k, v|
        if v.is_a?(Hash)
          walk(v) do |k2, v2|
            yield "#{k}.#{k2}", v2
          end
        else
          yield k, v
        end
      end
    end
  end
end
