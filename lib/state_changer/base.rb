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

    # ............................................................

    def self.register_transition(event_name, path, &block)
      from_state = path.keys.first
      to_state = path.values.first

      transition_container.register(event_name, nil, meta: { from: from_state, to: to_state }, &block)
    end

    def self.transition_container
      @transition_container ||= StateChanger::Container.new
    end
  end
end
