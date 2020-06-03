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

