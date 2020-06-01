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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davydovanton/state_changer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/davydovanton/state_changer/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StateChanger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davydovanton/state_changer/blob/master/CODE_OF_CONDUCT.md).
