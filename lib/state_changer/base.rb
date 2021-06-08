# frozen_string_literal: true

require 'state_changer/container'
require 'forwardable'

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

    def self.register_transition(event_name, path, &block)
      from_state = path.keys.first
      to_state = path.values.first

      transition_container.register(event_name, block, { from: from_state, to: to_state })
    end

    def self.transition_container
      @transition_container ||= StateChanger::Container.new
    end

    def call(event_name, data)
      states = select_states(data)
      raise StateChanger::WrongStateError if states.empty?

      # TODO: use condition for getting more than one initial state for data
      state = states.first
      transition_key = transition_key(event_name, state)
      raise StateChanger::WrongTransitionError if transition_key.nil?

      transition_container.get_by_full_key(transition_key).call(data.clone)
    end

    def transitions(data)
      states = select_states(data)
      transition_container.full_keys.select { |i| states.include? i.last[:from].to_s }
    end

    extend Forwardable

    def_delegators 'self.class', :state?, :transition_container, :state_container

    private :transition_container, :state_container

    private

    def transition_key(event_name, state)
      transition_container.full_keys.detect do |t|
        t.first == event_name.to_s && t.last[:from].to_s == state
      end
    end

    def select_states(data)
      state_container.keys.select { |state| state_container[state].call(data) }
    end
  end
end
