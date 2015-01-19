Feature: Generating an RSpec Spec from an RSpec Expectation

  Background:
    Given a file named "spec_helper.rb" with:
    """ruby
    require 'central_intelligence'

    RSpec.configure do |config|
      config.before(:all) do
        CentralIntelligence.reset
      end

      config.after(:all) do
        CentralIntelligence.print_report
      end
    end
    """


  Scenario: Simple
    Given a file named "top_level_spec.rb" with:
    """ruby
    require 'spec_helper'
    require 'person'

    describe "First day at work" do

      it "starts with an introduction" do
        boss = Person.new('Dick', 'Jones')
        expect(boss).to receive(:full_name).and_return("Dick Jones")
        expect(boss.welcome).to eq "Welcome to OCP, I'm Dick Jones"
      end

    end
    """
    And a file named "person.rb" with:
    """ruby
    class Person

      def initialize(firstname, lastname)
      end

      def welcome
        "Welcome to OCP, I'm #{full_name}"
      end

    end
    """

    When I run `rspec top_level_spec.rb`
    Then it should pass with:
    """
    Specs have been generated based on mocks you aren't currentl testing.
    """
    And there should be a file named "generated_specs/person_spec.rb" with:
    """
    describe Person do

      describe "#full_name" do

        it "returns the correct value" do
          satisfy "call to Person#full_name"
          instance = described_class.new
          expect(instance.full_name).to eq("Dick Jones")
        end

      end
    end
    """

