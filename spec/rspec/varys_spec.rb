require 'rspec'
require 'rspec/varys'


class Person

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def welcome
    "Welcome to OCP, I'm #{full_name}"
  end

  def full_name
    join_names(@first_name, @last_name)
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

    it "parses parameters" do
      described_class.reset
      confirm(Person.new 'Dick', 'Jones').can receive(:full_name).with(:blah).and_return("Dick Jones")
      expect(described_class.confirmed_messages).to match_array([{
        class_name: 'Person',
        message: :full_name,
        args: [:blah],
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
      type: 'instance',
      message: :a_message,
      args: [:a_parameter],
      return_value: 42
    }])
  end


  context "given the test-suite calls a mocked method" do
    context "with no parameters" do

      let(:recognised_specs) {
        [
          {
            class_name: 'Person',
            type: 'instance',
            message: :full_name,
            args: [],
            return_value: "Dick Jones"
          }
        ]
      }

      before do
        described_class.reset

        dick = Person.new('Dick', 'Jones')
        expect(dick).to receive(:full_name).and_return("Dick Jones")
        expect(dick.welcome).to eq "Welcome to OCP, I'm Dick Jones"
      end

      it "record the methods called" do
        expect(described_class.recorded_messages).to match_array(recognised_specs)
      end

    end

    context "with parameters" do

      let(:recognised_specs) {
        [
          {
            class_name: 'Person',
            type: 'instance',
            message: :join_names,
            args: ["Dick", "Jones"],
            return_value: "Dick Jones"
          }
        ]
      }

      before do
        described_class.reset

        dick = Person.new('Dick', 'Jones')
        expect(dick).to receive(:join_names).with("Dick", "Jones").and_return("Dick Jones")
        expect(dick.welcome).to eq "Welcome to OCP, I'm Dick Jones"
      end

      it "records that the method was called" do
        expect(described_class.recorded_messages).to match_array(recognised_specs)
      end

    end
  end

end

