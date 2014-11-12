lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'usmu/version'

def current_gems
  Dir["pkg/usmu-#{Usmu::VERSION}*.gem"]
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'test/spec/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'test/features'
end

desc 'Run all test scripts'
task :test => [:clean, :spec, :features]

desc 'Run CI test suite'
task :ci => [:test]

desc 'Clean up after tests'
task :clean do
  [
      'coverage',
      'test/site/site',
      current_gems,
  ].flatten.each do |f|
    rm_r f if File.exist? f
  end
end

namespace :gem do
  desc 'Build gems'
  task :build => [:clean] do
    mkdir 'pkg' unless File.exist? 'pkg'
    Dir['*.gemspec'].each do |gemspec|
      sh "gem build #{gemspec}"
    end
    Dir['*.gem'].each do |gem|
      mv gem, "pkg/#{gem}"
    end
  end

  desc 'Install gem'
  task :install => ['gem:build'] do
    if RUBY_PLATFORM == 'java'
      sh "gem install pkg/usmu-#{Usmu::VERSION}-java.gem"
    else
      sh "gem install pkg/usmu-#{Usmu::VERSION}.gem"
    end
  end

  desc 'Deploy gems to rubygems'
  task :deploy => ['gem:build'] do
    current_gems.each do |gem|
      sh "gem push #{gem}"
    end
    sh "git tag #{Usmu::VERSION}" if File.exist? '.git'
  end
end
