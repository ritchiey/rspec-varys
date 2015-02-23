[![Gem Version](https://badge.fury.io/rb/rspec-varys.svg)](http://badge.fury.io/rb/rspec-varys)

# Rspec::Varys

Generate RSpec specs from intelligence gathered from doubles and spies.  This is an experiment to see if a top-down TDD work-flow can be improved by partially automating the creation of lower level specs.

When you define a test-double in your spec:

```ruby
describe ExampleClass, "#max_margin_for" do
  it "returns the maximum margin for the supplied text" do
    allow(subject).to receive(:margin_for).and_return(2, 4)
    expect(subject.max_margin_for("  unindent line\n    indented line\n")).to eq(4)
  end
end
```

And your code calls it:

```ruby
class ExampleClass
  def max_margin_for(text)
    text.split("\n").map {|line| margin_for(line)}.max
  end
end
```


Varys will generate the corresponding specs so you can verify the validity of your test-doubles:

```ruby
# Generated by Varys:

describe ExampleClass, "#margin_for" do
  it "returns something" do
    confirm(subject).can receive(:margin_for).with("  unindent line").and_return(2)
    skip "remove this line once implemented"
    expect(subject.margin_for("  unindent line")).to eq(2)
  end
end

describe ExampleClass, "#margin_for" do
  it "returns something" do
    confirm(subject).can receive(:margin_for).with("    indented line").and_return(4)
    skip "remove this line once implemented"
    expect(subject.margin_for("    indented line")).to eq(4)
  end
end
```

## Limitations

Varys is very early release software and it has many limitations. If you find one, please check the Github issues and add it if it's not already listed.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-varys'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-varys

## Configuration

Add these lines to your `spec/spec_helper.rb`:

```ruby
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
```

## Usage

See the [Cucumber features](https://relishapp.com/spechero/rspec-varys/docs) for examples of intended usage or watch [this screencast](https://vimeo.com/119725799) for a simple tutorial.


## Contributing

1. Fork it ( https://github.com/ritchiey/rspec-varys/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
