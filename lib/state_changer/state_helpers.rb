# frozen_string_literal: true

module StateChanger
  module StateHelpers
    def state(state_name, &block)
      method_name = "#{state_name}?"
      klass = self
      helper_module = Module.new do |m|
        m.define_method method_name do |data|
          klass.state?(state_name, data)
        end
      end
      include helper_module unless method_defined? method_name
      extend helper_module unless singleton_class.method_defined? method_name
      super
    end
  end
end
