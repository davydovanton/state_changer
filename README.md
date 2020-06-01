# StateChanger

**Proof of Concept**

A simple state machine which will change state for each transition and work for any type of data.

## Motivation

You can find a lot of state machine libraries in the ruby ecosystem. All of them are great and I suggest using [aasm](https://github.com/aasm/aasm) and [state_machines](https://github.com/state-machines/state_machines) libraries.

But I found 3 critical problems for me which I see in all libraries and which I have no idea how to fix while using libraries:

1. I want to use any type of data, not only ruby mutable objects. For example, I can use dry-struct, immutable entities, and good old ruby hash. In this case, I can't just inject a state machine inside an object because I can't mutate state **or** it's just impossible to inject something inside the object.
2. Sometimes state transition means not only changing one filed for the state. You also need to change some fields like `deleted_at`, `archived`, or something like this. In this case, you can use it after callback or create a separate method where you'll call transition plus mutate data. But I want to see all changes which I need to do in transition in one place instead of checking transition rules + some callbacks or methods where I call transition logic. 
3. I want to control state transition on any events, It's mean that I want to use "result" object and I want to add some error messages for users if something wrong.

All these problems were a motivator for creating this library and that's why I started thinking can I use "functional approach" to make state machine better.

## Philosophy

1. The separation between state machine and data. It's mean that the state machine is not a part of the data object;
2. Allow to determinate how exactly you want to mutate state for each transition;
3. Make possible to detect state based on any type of data;
4. Make it simple and dependency-free. But also, I want to implement extensions behavior for everyone who wants to use something specific;

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'state_changer'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install state_changer

## Usage

### Base
#### Container

For using `StateChanger` library you need to create a container object which will contain state definition and transitions:

```ruby
class StateMachine < StateChanger::Container
end
```

All container classes don't contain global state, it's mean that you can create different state machines for one data:

```ruby
class OrderStateMachine < StateChanger::Container
end

class NewOrderStateMachine < StateChanger::Container
end
```
#### Defining State

For defining specific state you need to use `state` method with block which should return bool value (it needs for detecting state). You can define any count of states and use any logic inside block:

```ruby
class StateMachine < StateChanger::Container
  state(:open) { |hash| hash[:status] == :open }
  state(:close) { |object| object.status == :open }
  state(:inactive) { |object| object.inactive? }
end
```

You can also use a seporate object with all states for spliting state definition:

```ruby
class States < StateChanger::StateMixin
  state(:open) { |hash| hash[:status] == :open }
  state(:close) { |object| object.status == :open }
  state(:inactive) { |object| object.inactive? }
end

class StateMachine < StateChanger::Container
  states States
end
```

#### Transition and events

For register transition in the container, you need to use `register_transition` method with the event name, targets, and block. In this block, you can do any manipulation with your data but state machine will return the value of block every time when you call it:

```ruby
class StateMachine < StateChanger::Container
  # switch - event name for calling transition 
  # red    - initial state for transition
  # green  - ended state
  register_transition(:switch, red: :green) do |data|
    data[:light] = 'green'
    data
  end

  # Also, you can put any objects inside block:
  register_transition(:add_item, empty: :active) do |order, item|
    # ...
  end

  # Or use array as a traget
  register_transition(:add_item, [:empty, :active] => :active) do |order, item|
    # ...
  end

  register_transition(:delete_item, active: [:empty, :active]) do |order, item_id|
    # ...
  end

  # Also, you can use different targets for one event
  register_transition(:switch, red: :green)    { |data| ... }
  register_transition(:switch, green: :yellow) { |data| ... }
  register_transition(:switch, yellow: :red)   { |data| ... }
end
```

#### Execution
After defining the list of states and register transitions you can create a new instance of state machine and call specific event:

```ruby
state_machine = StateMachine.new
state_machine.call(:event_name, object)
# => this call will return a new object with changed state
```

Also, each `StateChanger` container contain one event `get_state` which returns state of the object:

```ruby
state_machine = StateMachine.new
state_machine.call(:get_state, object)
# => paid
```

#### Debugging and audit events

For debug prespective `StateChanger` container also sends events for each transition call. You can handle this events by adding handler logic:

```ruby
class StateMachine < StateChanger::Container
  handle_event(:transited) do |transition_name, from, to, old_payload, new_payload|
    logger.info('...')
  end
end
```

### Persist state to DB

It's a common practice to store state to DB in state machine call:

```ruby
job.aasm.fire!(:run) # saved

```
`StateChanger` try to use other way and separate persist and transition logic:

```ruby
# With AR
paid_order = state_machine.call(:pay, order)
paid_order.save

# With rom or hanami-model
paid_order = state_machine.call(:pay, order)
repo.update(paid_order.id, paid_order)
```

### Traffic light example
```ruby
class TrafficLightStateMachine < StateChanger::Container
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

state_machine = TrafficLightStateMachine.new
traffic_light = { street: 'B J. Comins, Licensed', light: 'red' }

new_traffic_light = state_machine.call(:switch, traffic_light)
# => { street: 'B J. Comins, Licensed', light: 'green' }

state_machine.call(:switch, new_traffic_light)
# => { street: 'B J. Comins, Licensed', light: 'yellow' }

# `state_machine.call` is pure function, it's mean that it always returns same result for the same data
state_machine.call(:switch, new_traffic_light)
# => { street: 'B J. Comins, Licensed', light: 'yellow' }

# Also, you can get state based on your data
state_machine.call(:get_state, traffic_light)
# => :red
state_machine.call(:get_state, new_traffic_light)
# => :green
```

### Order flow example

```ruby
class OrderStateMachine
  state(:empty)  { |order| order.items.empty? && order.payment.nil? }
  state(:active) { |order| order.items.any? && order.payment.nil? }
  state(:paid)   { |order| order.payment }

  register_transition(:add_item, [:empty, :active] => :active) do |order, item_id|
    order.items << item
    order
  end

  register_transition(:remove_item, active: [:empty, :active]) do |order, item_id|
    order.remove_item(item_id)
    order
  end

  register_transition(:pay, active: :paid) do |order|
    order.pay
    order
  end
end

state_machine = OrderStateMachine.new

order = Order.new(items: [])
item = { title: 'new book' }

state_machine.call(:pay, order)
# => returns error object because empty order can't be paid

active_order = state_machine.call(:add_item, order, item)
# => order with one item in 'active' state

paid_order = state_machine.call(:pay, active_order)
# => order with paid status

state_machine.call(:add_item, paid_order, item)
# => returns error again because state invalid for transition
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/state_changer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/davydovanton/state_changer/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StateChanger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davydovanton/state_changer/blob/master/CODE_OF_CONDUCT.md).
