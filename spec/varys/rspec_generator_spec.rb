require 'spec_helper'
require_relative '../../lib/rspec/varys/rspec_generator'

describe RSpec::Varys::RSpecGenerator do

  describe ".process_specs" do

    context "given a file YAML file with one missing spec with arguments" do
      let(:specs) {
        YAML.load <<-SPECS
---
:untested_stubs:
- :class_name: Person
  :method: full_name
  :arguments:
    - Dick
    - Jones
  :returns: Dick Jones
SPECS
      }

      it "generates the spec" do
        output = ""
        StringIO.open(output, 'w') do |file|
          described_class.process_specs(specs, file)
        end
        expect(output).to eq <<-EOF
describe Person, "#full_name" do

  it "returns something" do
    confirm(subject).can receive(:full_name).with("Dick", "Jones").and_return("Dick Jones")
    skip "remove this line once implemented"
    expect(subject.full_name("Dick", "Jones")).to eq("Dick Jones")
  end

end


EOF
      end
    end


    context "given a file YAML file with one missing spec" do
      let(:specs) {
        YAML.load <<-SPECS
---
:untested_stubs:
- :class_name: Person
  :method: full_name
  :returns: Dick Jones
SPECS
      }

      it "generates the spec" do
        output = ""
        StringIO.open(output, 'w') do |file|
          described_class.process_specs(specs, file)
        end
        expect(output).to eq <<-EOF
describe Person, "#full_name" do

  it "returns something" do
    confirm(subject).can receive(:full_name).and_return("Dick Jones")
    skip "remove this line once implemented"
    expect(subject.full_name).to eq("Dick Jones")
  end

end


EOF
      end
    end

  end

end
