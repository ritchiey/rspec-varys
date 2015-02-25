Feature: Generating an RSpec Spec from an RSpec Expectation

  Background:
    Given a file named "spec_helper.rb" with:
    """ruby
    $:.unshift File.expand_path('../../lib', File.dirname(__FILE__))

    require "rspec/varys"
    require "rspec/varys/rspec_generator"

    RSpec.configure do |config|

      config.include RSpec::Varys::DSL

      config.before(:suite) do
        RSpec::Varys.reset
      end

      config.after(:suite) do
        RSpec::Varys.print_report
        RSpec::Varys::RSpecGenerator.run
      end
    end
    """


  Scenario: For a test double
    Given a file named "top_level_spec.rb" with:
    """ruby
    require_relative 'spec_helper'
    require_relative 'person'

    describe "First day at work" do

      it "starts with an introduction" do
        name = double('Name', full_name: "Dick Jones")
        boss = Person.new(name)
        expect(boss.welcome).to eq "Welcome to OCP, I'm Dick Jones"
      end

    end
    """
    And a file named "person.rb" with:
    """ruby
    class Person

      def initialize(name)
        @name = name
      end

      def welcome
        "Welcome to OCP, I'm #{@name.full_name}"
      end

    end
    """

    When I run `rspec top_level_spec.rb`
    Then it should pass with:
    """ruby
    Specs have been generated based on mocks you aren't currently testing.
    """
    And the file "varys.yaml" should contain:
    """yaml
    ---
    :untested_stubs:
    - :class_name: Name
      :type: instance
      :method: full_name
      :returns: Dick Jones
    """

    And the file "generated_specs.rb" should contain:
    """ruby
    describe Name, "#full_name" do

      it "returns something" do
        confirm(subject).can receive(:full_name).and_return("Dick Jones")
        skip "remove this line once implemented"
        expect(subject.full_name).to eq("Dick Jones")
      end

    end


    """
  Scenario: For a class method
    Given a file named "top_level_spec.rb" with:
    """ruby
    require_relative 'spec_helper'
    require_relative 'person'

    describe "First day at work" do

      it "starts with an introduction" do
        boss = Person.new('Dick', 'Jones')
        allow(Person).to receive(:full_name).with("Dick", "Jones").and_return("Dick Jones")
        expect(boss.welcome).to eq "Welcome to OCP, I'm Dick Jones"
      end

    end
    """
    And a file named "person.rb" with:
    """ruby
    class Person

      def initialize(firstname, lastname)
        @firstname = firstname
        @lastname = lastname
      end

      def welcome
        "Welcome to OCP, I'm #{Person.full_name(@firstname, @lastname)}"
      end

    end
    """

    When I run `rspec top_level_spec.rb`
    Then it should pass with:
    """ruby
    Specs have been generated based on mocks you aren't currently testing.
    """
    And the file "varys.yaml" should contain:
    """yaml
    ---
    :untested_stubs:
    - :class_name: Person
      :type: class
      :method: full_name
      :returns: Dick Jones
      :arguments:
      - Dick
      - Jones
    """

    And the file "generated_specs.rb" should contain:
    """ruby
    describe Person, ".full_name" do

      it "returns something" do
        confirm(described_class).can receive(:full_name).with("Dick", "Jones").and_return("Dick Jones")
        skip "remove this line once implemented"
        expect(described_class.full_name("Dick", "Jones")).to eq("Dick Jones")
      end

    end


    """


  Scenario: For a single unmatched expectation
    Given a file named "top_level_spec.rb" with:
    """ruby
    require_relative 'spec_helper'
    require_relative 'person'

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
    """ruby
    Specs have been generated based on mocks you aren't currently testing.
    """
    And the file "varys.yaml" should contain:
    """yaml
    ---
    :untested_stubs:
    - :class_name: Person
      :type: instance
      :method: full_name
      :returns: Dick Jones
    """

    And the file "generated_specs.rb" should contain:
    """ruby
    describe Person, "#full_name" do

      it "returns something" do
        confirm(subject).can receive(:full_name).and_return("Dick Jones")
        skip "remove this line once implemented"
        expect(subject.full_name).to eq("Dick Jones")
      end

    end


    """


  Scenario: For two unmatched expectations on the same class
    Given a file named "top_level_spec.rb" with:
    """ruby
    require_relative 'spec_helper'
    require_relative 'person'

    describe "First day at work" do

      it "starts with an introduction" do
        boss = Person.new('Dick', 'Jones')
        expect(boss).to receive(:full_name).and_return("Dick Jones")
        expect(boss).to receive(:title).and_return("Vice President")
        expect(boss.welcome).to eq "Welcome to OCP, I'm Vice President Dick Jones"
      end

    end
    """
    And a file named "person.rb" with:
    """ruby
    class Person

      def initialize(firstname, lastname)
      end

      def welcome
        "Welcome to OCP, I'm #{title} #{full_name}"
      end

    end
    """

    When I run `rspec top_level_spec.rb`
    Then it should pass with:
    """ruby
    Specs have been generated based on mocks you aren't currently testing.
    """
    And the file "varys.yaml" should contain:
    """yaml
    ---
    :untested_stubs:
    - :class_name: Person
      :type: instance
      :method: title
      :returns: Vice President
    - :class_name: Person
      :type: instance
      :method: full_name
      :returns: Dick Jones
    """

    And the file "generated_specs.rb" should contain:
    """ruby
    describe Person, "#title" do

      it "returns something" do
        confirm(subject).can receive(:title).and_return("Vice President")
        skip "remove this line once implemented"
        expect(subject.title).to eq("Vice President")
      end

    end


    describe Person, "#full_name" do

      it "returns something" do
        confirm(subject).can receive(:full_name).and_return("Dick Jones")
        skip "remove this line once implemented"
        expect(subject.full_name).to eq("Dick Jones")
      end

    end


    """


  Scenario: For one matched and one unmatched expectation
    Given a file named "top_level_spec.rb" with:
    """ruby
    require_relative 'spec_helper'
    require_relative 'person'

    describe "First day at work" do

      it "starts with an introduction" do
        boss = Person.new('Dick', 'Jones')
        allow(boss).to receive(:full_name).and_return("Dick Jones")
        allow(boss).to receive(:title).and_return("Vice President")
        expect(boss.welcome).to eq "Welcome to OCP, I'm Vice President Dick Jones"
      end

    end

    describe Person do

      subject { described_class.new('Dick', 'Jones') }

      describe "#full_name" do

        it "returns the correct value" do
          confirm(subject).can receive(:full_name).and_return("Dick Jones")
          # ...
        end

      end

    end

    """
    And a file named "person.rb" with:
    """ruby
    class Person

      def initialize(firstname, lastname)
      end

      def welcome
        "Welcome to OCP, I'm #{title} #{full_name}"
      end

    end
    """

    When I run `rspec top_level_spec.rb`
    Then it should pass with:
    """ruby
    Specs have been generated based on mocks you aren't currently testing.
    """
    And the file "varys.yaml" should contain:
    """yaml
    ---
    :untested_stubs:
    - :class_name: Person
      :type: instance
      :method: title
      :returns: Vice President
    """

  Scenario: For an expectation with parameters
    Given a file named "top_level_spec.rb" with:
    """ruby
    require_relative 'spec_helper'
    require_relative 'person'

    describe Person do

      subject { described_class.new('Dick', 'Jones') }

      describe "#full_name" do

        it "returns the correct value" do
          expect(subject).to receive(:join_names).with("Dick", "Jones").and_return("Dick Jones")
          subject.full_name
        end

      end

    end

    """
    And a file named "person.rb" with:
    """ruby
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
    """

    When I run `rspec top_level_spec.rb`
    Then it should pass with:
    """ruby
    Specs have been generated based on mocks you aren't currently testing.
    """
    And the file "varys.yaml" should contain:
    """yaml
    ---
    :untested_stubs:
    - :class_name: Person
      :type: instance
      :method: join_names
      :returns: Dick Jones
      :arguments:
      - Dick
      - Jones
    """

    And the file "generated_specs.rb" should contain:
    """ruby
    describe Person, "#join_names" do

      it "returns something" do
        confirm(subject).can receive(:join_names).with("Dick", "Jones").and_return("Dick Jones")
        skip "remove this line once implemented"
        expect(subject.join_names("Dick", "Jones")).to eq("Dick Jones")
      end

    end


    """




