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
describe #{spec[:class_name]}, "#{class_method?(spec) ? '.' : '#'}#{spec[:method]}" do

  it "returns something" do
    confirm(#{sut(spec)}).can receive(:#{spec[:method]})#{with_args_if_any(spec)}.and_return(#{serialize spec[:returns]})
    skip "remove this line once implemented"
    expect(#{sut(spec)}.#{spec[:method]}#{args_if_any(spec)}).to eq(#{serialize spec[:returns]})
  end

end


      EOF
    end
  end

  def self.with_args_if_any(call)
    args = call[:arguments]
    (args && args.length > 0) ?  ".with(#{args.map{|a| serialize a}.join ', '})" : ""
  end

  def self.args_if_any(call)
    args = call[:arguments]
    (args && args.length > 0) ?  "(#{args.map{|a| serialize a}.join ', '})" : ""
  end

  # Attempt to recreate the source-code to represent this argument in the setup
  # for our generated spec.
  def self.serialize(arg)
    if %w(Array Hash Float Fixnum String NilClass TrueClass FalseClass).include? arg.class.name
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

  def self.class_method?(call)
    call[:type] == 'class'
  end

  def self.sut(call)
    class_method?(call) ? "described_class" : "subject"
  end

end
