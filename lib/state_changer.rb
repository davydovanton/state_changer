# frozen_string_literal: true

require 'state_changer/version'
require 'state_changer/base'

module StateChanger
  class Error < StandardError; end

  class WrongStateError < Error; end

  class WrongTransitionError < Error; end
end
