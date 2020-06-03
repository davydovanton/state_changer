module StateChanger
  class Container
    def initialize
      @container = {}
    end

    def register(key, value = nil, meta: {}, &block)
      if value
        @container[[key.to_s, meta]] = value
      else
        @container[[key.to_s, meta]] = block
      end
    end

    def [](key, meta: {})
      full_key = @container.keys.detect { |k| k.first == key.to_s }
      @container[full_key]
    end

    def keys
      @container.keys.map(&:first)
    end

    def full_keys
      @container.keys
    end
  end
end
