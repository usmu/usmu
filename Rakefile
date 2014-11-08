require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'test/spec/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'test/features'
end

desc 'Run all test scripts'
task :test => [:spec, :features]

desc 'Run CI test suite'
task :ci => [:spec]
