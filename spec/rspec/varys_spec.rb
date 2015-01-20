require 'rspec'
require 'rspec/varys'
require 'pry'

  class Person

    def initialize(firstname, lastname)

    end

    def welcome
      "Welcome to OCP, I'm #{full_name}"
    end

  end

describe RSpec::Varys do

  describe ".unconfirmed_messages" do

    it "returns the messages that don't already have specs" do
      expect(described_class).to receive(:confirmed_messages).and_return([
        { class_name: 'Person', message: :full_name, args: [], return_value: "Dick Jones" }
      ])
      expect(described_class).to receive(:recorded_messages).and_return([
        {:class_name=>"Person", :message=>:full_name, :args=>[], :return_value=>"Dick Jones"},
        { class_name: 'Object', message: :a_message, args: [:a_parameter], return_value: 42 }
      ])
      expect(described_class.unconfirmed_messages).to match_array([
        { class_name: 'Object', message: :a_message, args: [:a_parameter], return_value: 42 }
      ])
    end
  end

  describe ".confirmed_messages" do

    include RSpec::Varys::DSL

    it "returns a list of expectations that have been satisfied" do
      confirm(Person.new 'Dick', 'Jones').can receive(:full_name).and_return("Dick Jones")
      expect(described_class.confirmed_messages).to match_array([{
      class_name: 'Person',
      message: :full_name,
      args: [],
      return_value: "Dick Jones"
    }])
    end

  end

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


  context "given the test-suite calls a mocked method" do

    let(:expected_spec) do
<<GENERATED
  describe "#full_name" do

    it "returns the correct value" do
      confirm(subject).can receive(:full_name).and_return("Dick Jones")
      instance = described_class.new
      expect(instance.full_name).to eq("Dick Jones")
    end

  end

GENERATED
    end

    before do
      described_class.reset

      dick = Person.new('Dick', 'Jones')
      expect(dick).to receive(:full_name).and_return("Dick Jones")
      expect(dick.welcome).to eq "Welcome to OCP, I'm Dick Jones"
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
      expect(described_class.generated_specs).to eq('Person' => [ expected_spec ])

    end

  end

end

