require 'pry'
require 'rspec'

class RSpec::Mocks::Proxy

  alias_method :old_message_received, :message_received

  def message_received(message, *args, &block)
    old_message_received(message, *args, &block).tap do |return_value|
      CentralIntelligence.record object, message, args, block, return_value
    end
  end

end


class CentralIntelligence

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
    @generated_specs = <<-GENERATED
describe Person do

  describe "#full_name" do

    it "returns the correct value" do
      # Generated constructor, please check
      person = Person.new
      # add any required setup here
      expect(person.full_name).to eq("Dick Jones")
    end

  end
end
GENERATED
  end

end


describe CentralIntelligence do

  it "records the messages sent to a spy" do

    CentralIntelligence.reset

    o = Object.new
    expect(o).to receive(:a_message).with(:a_parameter).and_return(42)
    o.a_message(:a_parameter)

    expect(CentralIntelligence.recorded_messages).to match_array([{
      class_name: 'Object',
      message: :a_message,
      args: [:a_parameter],
      return_value: 42
    }])
  end

  class Person

    def initialize(firstname, lastname)

    end

    def welcome
      "Welcome to OCP, I'm #{full_name}"
    end

  end


  it "can generate required specs" do
    CentralIntelligence.reset

    # run our top-level spec here
    #
    bob = Person.new('Dick', 'Jones')
    expect(bob).to receive(:full_name).and_return("Dick Jones")
    expect(bob.welcome).to eq "Welcome to OCP, I'm Dick Jones"

    # did it correctly record the method called
    expect(CentralIntelligence.recorded_messages).to match_array(
      [
        {
          class_name: 'Person',
          message: :full_name,
          args: [],
          return_value: "Dick Jones"
        }
      ]
    )

    # did it generate an in-memory version of the specs?
    expect(CentralIntelligence.generated_specs).to eq <<-GENERATED
describe Person do

  describe "#full_name" do

    it "returns the correct value" do
      # Generated constructor, please check
      person = Person.new
      # add any required setup here
      expect(person.full_name).to eq("Dick Jones")
    end

  end
end
GENERATED
  end

end




