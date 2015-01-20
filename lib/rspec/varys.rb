require "fileutils"

class RSpec::Mocks::Proxy

  alias_method :old_message_received, :message_received

  def message_received(message, *args, &block)
    old_message_received(message, *args, &block).tap do |return_value|
      RSpec::Varys.record object, message, args, block, return_value
    end
  end

end


class RSpec::Varys

  def self.recorded_messages
    @recorded_messages
  end

  def self.generated_specs
    @generated_specs ||= generate_specs
  end

  def self.reset
    @recorded_messages = []
    @generated_specs = nil
  end

  def self.record(object, message, args, block, return_value)
    @recorded_messages << {
      class_name: object.class.name,
      message: message,
      args: args,
      return_value: return_value
    }
  end

  def self.generate_specs
    {}.tap do |generated_specs|
      @recorded_messages.each do |s|
        generated_specs[s[:class_name]] ||= []
        generated_specs[s[:class_name]] << generate_spec(s)
      end
    end
  end


  def self.generate_spec(s)
    <<-GENERATED
  describe "##{s[:message]}" do

    it "returns the correct value" do
      satisfy "call to #{s[:class_name]}##{s[:message]}"
      instance = described_class.new
      expect(instance.#{s[:message]}).to eq(#{serialize s[:return_value]})
    end

  end

      GENERATED
  end

  def self.print_report
    dest_path = "generated_specs"
    FileUtils.mkdir_p dest_path
    generated_specs.each do |class_name, specs|
      File.open("#{dest_path}/#{underscore class_name}_spec.rb", 'w') do |file|
        file.write "describe #{class_name} do\n\n"
        specs.each do |spec|
          file.write(spec)
        end
        file.write "end"
      end
    end
    puts "Specs have been generated based on mocks you aren't currently testing."
  end

  def self.underscore(camel_cased_word)
    camel_cased_word.downcase
  end

  # Attempt to recreate the source-code to represent this argument in the setup
  # for our generated spec.
  def self.serialize(arg)
    if %w(Array Hash Float Fixnum String).include? arg.class.name
      arg.pretty_inspect.chop
    else
      guess_constructor arg
    end
  end

  # Don't recognise the type so we don't know how to recreate it
  # in source code. So we'll take a guess at what might work and
  # let the user fix it up if necessary.
  def self.guess_constructor(arg)
    "#{arg.class.name}.new(#{serialize(arg.to_s)})"
  end
end

