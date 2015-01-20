require 'rspec'
require 'rspec/varys'


describe RSpec::Varys do

  it "records the messages sent to a spy" do

    described_class.reset

    o = Object.new
    expect(o).to receive(:a_message).with(:a_parameter).and_return(42)
    o.a_message(:a_parameter)

    expect(described_class.recorded_messages).to match_array([{
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

  context "given the test-suite calls a mocked method" do

    let(:expected_spec) do
<<GENERATED
describe Person do

  describe "#full_name" do

    it "returns the correct value" do
      satisfy "call to Person#full_name"
      instance = described_class.new
      expect(instance.full_name).to eq("Dick Jones")
    end

  end
end
GENERATED
    end

    before do
      described_class.reset

      bob = Person.new('Dick', 'Jones')
      expect(bob).to receive(:full_name).and_return("Dick Jones")
      expect(bob.welcome).to eq "Welcome to OCP, I'm Dick Jones"
    end

    it "can generate required specs" do
      # did it correctly record the method called
      expect(described_class.recorded_messages).to match_array(
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
      expect(described_class.generated_specs).to match_array([expected_spec])

    end

  end

end

