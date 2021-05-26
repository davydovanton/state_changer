require_relative './helpers/traffic_light'

RSpec.describe StateChanger::Base do
  describe '::state' do
    it 'registers new state in specific container' do
      expect(TrafficLightStateMachine.state_container.keys).to eq ['red', 'green', 'yellow']
    end
  end

  describe '::state?' do
    it 'checks data for specific state' do
      expect(TrafficLightStateMachine.state?(:red, { light: 'red' })).to eq true
      expect(TrafficLightStateMachine.state?(:red, { light: 'green' })).to eq false
    end
  end

  describe '::state_container' do
    it { expect(TrafficLightStateMachine.state_container).to be_a(StateChanger::Container) }
  end

  describe '::transition_container' do
    it { expect(TrafficLightStateMachine.transition_container).to be_a(StateChanger::Container) }
  end

  describe '::register_transition' do
    it 'registers new transitions' do
      transitions = TrafficLightStateMachine.transition_container.full_keys

      expect(transitions).to eq([
        ['switch', { from: :red, to: :green }],
        ['switch', { from: :green, to: :yellow }],
        ['switch', { from: :yellow, to: :red }],
      ])
    end
  end

  describe '#call' do
    let(:machine) { TrafficLightStateMachine.new }

    it 'returns "Error" if data has invalid state' do
      data = { light: 'invalid' }

      expect(machine.call(:switch, data)).to eq('Error')
    end

    it 'returns new data mapped to next transition state' do
      data = { light: 'red' }

      expect(machine.call(:switch, data)).to eq(light: 'green')
    end

    it 'returns not mutated data mapped to next transition state' do
      data = { light: 'red' }

      expect(machine.call(:switch, data)).to eq(light: 'green')
      expect(machine.call(:switch, data)).to eq(light: 'green')
    end
  end

  describe '#transitions' do
    let(:machine) { TrafficLightStateMachine.new }

    it 'returns list of allowed transitions' do
      data = { light: 'red' }

      expect(machine.transitions(data)).to eq([
        ['switch', { from: :red, to: :green }]
      ])
    end

    it 'returns empty list if no allowed transitions found for current state' do
      data = { light: 'cyan' }

      expect(machine.transitions(data)).to eq([])
    end
  end
end
