lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec/core/rake_task'
require 'usmu/version'

def current_gems
  Dir["pkg/usmu-#{Usmu::VERSION}*.gem"]
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'test/spec'
end

desc 'Run all test scripts'
task :test => [:clean, :spec]

desc 'Run CI test suite'
task :ci => [:test]

desc 'Clean up after tests'
task :clean do
  [
      'tmp',
      'test/coverage',
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

# (mostly) borrowed from: https://gist.github.com/mcansky/802396
desc 'generate changelog with nice clean output'
task :changelog, :since_c, :until_c do |t,args|
  since_c = args[:since_c] || `git tag | head -1`.chomp
  until_c = args[:until_c]
  cmd=`git log --pretty='format:%ci::::%an <%ae>::::%s::::%H' #{since_c}..#{until_c}`

  entries = Hash.new
  changelog_content = "\#\# #{Usmu::VERSION}\n\n"

  cmd.lines.each do |entry|
    date, author, subject, hash = entry.chomp.split('::::')
    entries[author] = Array.new unless entries[author]
    day = date.split(' ').first
    entries[author] << "#{subject} (#{hash})" unless subject =~ /Merge/
  end

  # generate clean output
  entries.keys.each do |author|
    changelog_content += author + "\n\n"
    entries[author].reverse.each { |entry| changelog_content += "* #{entry}\n" }
  end

  puts changelog_content
end
