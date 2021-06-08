# frozen_string_literal: true

require 'state_changer/version'
require 'state_changer/base'

module StateChanger
  class WrongStateError < StandardError; end
  class WrongTransitionError < StandardError; end
end
