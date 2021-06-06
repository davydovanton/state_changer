# frozen_string_literal: true

require 'spec_helper'
require 'helpers/machine_with_helpers'

RSpec.describe StateChanger::StateHelpers do
  describe '#<state_name>?' do
    let(:machine) { MachineWithHelpers.new }

    it 'is returns true if it is a current state' do
      expect(machine.first?(['first'])).to be_truthy
    end

    it 'works inside state declaration' do
      expect(machine.both?(%w[first second])).to be_truthy
    end

    it 'fails if inner state check fails' do
      expect(machine.both?([nil, 'second'])).to be_falsy
    end

    it 'doesn\'t redefine existing methods' do
      expect(machine.test?).to be_eql 'test'
    end
  end

  describe '.<state_name>?' do
    let(:machine) { MachineWithHelpers }

    it 'is returns true if it is a current state' do
      expect(machine.first?(['first'])).to be_truthy
    end

    it 'works inside state declaration' do
      expect(machine.both?(%w[first second])).to be_truthy
    end

    it 'fails if inner state check fails' do
      expect(machine.both?([nil, 'second'])).to be_falsy
    end

    it 'doesn\'t redefine existing methods' do
      expect(machine.test?).to be_eql 'test'
    end
  end
end
