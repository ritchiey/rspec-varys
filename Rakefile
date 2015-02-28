require "bundler/gem_tasks"

require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'


Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
end

task :default => [:spec, :features]
RSpec::Core::RakeTask.new
