# frozen_string_literal: true
class ParentMachine < StateChanger::Base
  def test?
    "test"
  end

  def self.test?
    "test"
  end
end

class MachineWithHelpers < ParentMachine
  extend StateChanger::StateHelpers

  state(:first) { |c| !c.first.nil? }
  state(:both) { |c| first?(c) && !c[1].nil? }
  state(:test) { false }
end
