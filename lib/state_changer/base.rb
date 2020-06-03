require "state_changer/container"

module StateChanger
  class Base
    def self.state(state_name, &block)
      state_container.register(state_name, block)
    end

    def self.state?(state_name, data)
      state_container[state_name].call(data)
    end

    def self.state_container
      @state_container ||= StateChanger::Container.new
    end
  end
end
