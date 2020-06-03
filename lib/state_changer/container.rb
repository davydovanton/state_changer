module StateChanger
  class Container
    def initialize
      @container = {}
    end

    def register(key, value = nil, &block)
      if value
        @container[key.to_s] = value
      else
        @container[key.to_s] = block
      end
    end

    def [](key)
      @container[key.to_s]
    end

    def keys
      @container.keys
    end
  end
end
