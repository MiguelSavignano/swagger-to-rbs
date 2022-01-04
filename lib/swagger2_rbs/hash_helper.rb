module Swagger2Rbs
  class HashHelper
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
