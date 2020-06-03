require_relative './../lib/state_changer'

class TrafficLightStateMachine < StateChanger::Base
  state(:red)    { |data| data[:light] == 'red' }
  state(:green)  { |data| data[:light] == 'green' }
  state(:yellow) { |data| data[:light] == 'yellow' }

  register_transition(:switch, red: :green) do |data|
    data[:light] = 'green'
    data
  end

  register_transition(:switch, green: :yellow) do |data|
    data[:light] = 'yellow'
    data
  end
  register_transition(:switch, yellow: :red) do |data|
    data[:light] = 'red'
    data
  end
end

puts 'Start a new example'
state_machine = TrafficLightStateMachine.new
traffic_light = { street: 'B J. Comins, Licensed', light: 'red' }

p traffic_light

new_traffic_light = state_machine.call(:switch, traffic_light)

p new_traffic_light

p state_machine.call(:switch, new_traffic_light)
p state_machine.call(:switch, new_traffic_light)

# state_machine.call(:get_state, traffic_light)
# state_machine.call(:get_state, new_traffic_light)
