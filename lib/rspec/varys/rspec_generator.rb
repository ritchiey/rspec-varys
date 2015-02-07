class RSpec::Varys::RSpecGenerator

  def self.run

    specs = YAML.load(File.read "varys.yaml")

    File.open('generated_specs.rb', 'w') do |file|
      process_specs(specs, file)
    end

  end

  def self.process_specs(specs, file)
    specs[:untested_stubs].each do |spec|
      file.puts <<-EOF
describe #{spec[:class_name]}, "##{spec[:method]}" do

  it "returns something" do
    expect(subject.#{spec[:method]}).to return(#{serialize spec[:returns]})
  end

end
      EOF
    end
  end

  # Attempt to recreate the source-code to represent this argument in the setup
  # for our generated spec.
  def self.serialize(arg)
    if %w(Array Hash Float Fixnum String).include? arg.class.name
      arg.pretty_inspect.chop
    else
      guess_constructor arg
    end
  end

  # Don't recognise the type so we don't know how to recreate it
  # in source code. So we'll take a guess at what might work and
  # let the user fix it up if necessary.
  def self.guess_constructor(arg)
    "#{arg.class.name}.new(#{serialize(arg.to_s)})"
  end

end
