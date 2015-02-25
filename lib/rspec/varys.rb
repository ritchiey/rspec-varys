require "rspec/varys/version"
require "fileutils"
require 'yaml'

module RSpec
  module Varys
    module DSL

      def confirm(object)
        Confirmation.new(object)
      end

      class Confirmation

        def initialize(object)
          @object = object
        end

        def can(ability)
          @ability = ability
          RSpec::Varys.confirmed_messages << to_expectation
        end

        private

        def to_expectation
          {
            class_name: class_name,
            message: message,
            args: args,
            return_value: return_value
          }
        end

        def args
          customization = customizations.find{|c| c.instance_variable_get('@method_name') == :with}
          (customization && customization.instance_variable_get('@args')) || []
        end

        def return_value
          customization = customizations.find{|c| c.instance_variable_get('@method_name') == :and_return}
          customization && customization.instance_variable_get('@args').first
        end

        def customizations
          @ability.instance_variable_get('@recorded_customizations')
        end

        def class_name
          @object.class.name
        end

        def message
          @ability.instance_variable_get('@message')
        end

      end
    end
  end
end


class RSpec::Mocks::Proxy

  alias_method :old_message_received, :message_received

  def message_received(message, *args, &block)
    old_message_received(message, *args, &block).tap do |return_value|
      RSpec::Varys.record object, message, args, block, return_value
    end
  end

end


module RSpec::Varys

  def self.confirmed_messages
    @confirmed_messages
  end

  def self.recorded_messages
    @recorded_messages
  end

  def self.reset
    @recorded_messages = []
    @generated_specs = nil
    @confirmed_messages = []
  end

  def self.record(object, message, args, block, return_value)
    @recorded_messages << {
      class_name: class_name_for(object),
      type:   type_for(object),
      message: message,
      args: args,
      return_value: return_value
    }
  end

  def self.type_for(object)
    object.kind_of?(Class) ? 'class' : 'instance'
  end

  def self.class_name_for(object)
    if object.kind_of? RSpec::Mocks::Double
      'Name'
    else
      object.kind_of?(Class) ? object.name : object.class.name
    end
  end


  def self.print_report
    open_yaml_file do |yaml_file|
      yaml_file.write YAML.dump(report)
    end
    puts "Specs have been generated based on mocks you aren't currently testing."
  end

  def self.report
    {
      untested_stubs: unconfirmed_messages.map do |call|
        {
          class_name:  call[:class_name],
          type:        call[:type],
          method:      call[:message].to_s,
          returns:     call[:return_value]
        }.merge(arguments_if_any(call))
      end
    }
  end

  def self.arguments_if_any(call)
    call[:args].length > 0 ?  { arguments: call[:args] } : { }
  end

  def self.open_yaml_file
    File.open("varys.yaml", 'w') do |io|
      yield io
    end
  end


  def self.unconfirmed_messages
    recorded_messages - confirmed_messages
  end

end

