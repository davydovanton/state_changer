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

      transition_container.register(event_name, block, { from: from_state, to: to_state })
    end

    def self.transition_container
      @transition_container ||= StateChanger::Container.new
    end

    # ............................................................

    def call(event_name, data)
      # 1. [DONE] get current state for data
      # 1.2. [DONE] return error if zero matches for state
      #
      # 2. event_name + from_state = value from transition_container
      # 3. execute transition
      #
      state_container = self.class.state_container
      transition_container = self.class.transition_container

      states = state_container.keys
        .map { |state| [state, state_container[state].call(data)] }
        .select { |state| state.last }
        .map(&:first)

      return 'Error' if states.empty?

      # TODO: use condition for getting more than one initial state for data
      state = states.first
      transition_key = transition_container
        .full_keys
        .detect { |t| t.first == event_name.to_s && t.last[:from].to_s == state }

      transition_container.get_by_full_key(transition_key).call(data.clone)
    end
  end
end
