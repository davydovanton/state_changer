RSpec.describe StateChanger::Base do
  class TrafficLightStateMachine < StateChanger::Base
    state(:red)    { |data| data[:light] == 'red' }
    state(:green)  { |data| data[:light] == 'green' }
    state(:yellow) { |data| data[:light] == 'yellow' }
  end

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
    it { expect(StateChanger::Base.state_container).to be_a(StateChanger::Container) }
  end
end
