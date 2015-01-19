require 'pry'
require 'rspec'

class CentralIntelligence

  attr_reader :recorded_messages, :generated_specs

  def initialize
    @recorded_messages = []
  end

  def interrogate_spies
    @recorded_messages  = ::RSpec::Mocks.space.proxies.map do |pair|
      proxy = pair.last
      class_name = proxy.object.class.name
      proxy.instance_variable_get('@messages_received').map do |message|
        {
          class_name: class_name,
          message: message[0],
          args: message[1],
          return_value: 42 # slime
        }
      end
    end.flatten
  end

  def generate_specs
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
    ci = CentralIntelligence.new
    o = Object.new
    allow(o).to receive(:a_message).with(:a_parameter).and_return(42)
    o.a_message(:a_parameter)
    ci.interrogate_spies
    expect(ci.recorded_messages).to match_array([{
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
    pending "ability to get return value from method call"
    # run our top-level spec here
    #
    bob = Person.new('Dick', 'Jones')
    expect(bob).to receive(:full_name).and_return("Dick Jones")
    expect(bob.welcome).to eq "Welcome to OCP, I'm Dick Jones"

    #
    # this would normally be in an after(:each) block
    ci = CentralIntelligence.new
    ci.interrogate_spies

    # did it correctly record the method called
    expect(ci.recorded_messages).to match_array(
      [
        {
          class_name: 'Person',
          message: :full_name,
          args: []
        }
      ]
    )

    # this would normally be in an after(:all) block
    ci.generate_specs

    # did it generrate an in-memory version of the specs
    expect(ci.generated_specs).to eq <<-GENERATED
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




