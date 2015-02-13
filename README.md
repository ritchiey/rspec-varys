[![Gem Version](https://badge.fury.io/rb/rspec-varys.svg)](http://badge.fury.io/rb/rspec-varys)

# Rspec::Varys

Generate RSpec specs from intelligence gathered from doubles and spies.

This is an experiment to see if a top-down TDD work-flow can be improved by partially automating the creation of lower level specs.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-varys'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-varys

## Configuration

Add these lines to your `spec/spec_helper.rb`:

    require "rspec/varys"
    require "rspec/varys/rspec_generator"

    RSpec.configure do |config|

      config.include RSpec::Varys::DSL

      config.before(:suite) do
        RSpec::Varys.reset
      end

      config.after(:suite) do

        # Required: create varys.yml
        RSpec::Varys.print_report

        # Optional: create generated_specs.yml from varys.yml
        RSpec::Varys::RSpecGenerator.run

      end
    end

## Usage

See the [Cucumber features](https://relishapp.com/spechero/rspec-varys/docs) for examples of intended usage.

## Contributing

1. Fork it ( https://github.com/ritchiey/rspec-varys/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
