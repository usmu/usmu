lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec/core/rake_task'
require 'usmu/version'

def current_gems
  Dir["pkg/usmu-#{Usmu::VERSION}*.gem"].sort_by &:length
end

def platforms
  %w(ruby java)
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec'
end

desc 'Start an IRB session with local code available'
task :irb do
  exec *%w{bundle exec irb}
end

desc 'Run all test scripts'
task :test => [:clean, :spec, :mutant]

desc 'Run mutation tests'
task :mutant, [:target] => [:clean] do |t,args|
  old = ENV.delete('CODECLIMATE_REPO_TOKEN')
  if `which mutant 2>&1 > /dev/null; echo \$?`.to_i != 0
    puts 'Mutant isn\'t supported on your platform. Please run these tests on MRI <= 2.1.5.'
  else
    sh 'bundle', 'exec', 'mutant',
       '--include', 'lib',
       '--require', 'usmu',
       '--require', 'usmu/deployment',
       '--use', 'rspec',
       # Interfaces and documentation classes
       '--ignore-subject', 'Usmu::Deployment::RemoteFileInterface*',
       '--ignore-subject', 'Usmu::Plugin::CoreHooks*',
       args[:target] || 'Usmu*'
  end
  ENV['CODECLIMATE_REPO_TOKEN'] = old unless old.nil?
end

desc 'Run CI test suite'
task :ci => [:clean, :spec]

desc 'Clean up after tests'
task :clean do
  [
      'doc',
      'tmp',
      'test-site/site',
      current_gems,
  ].flatten.each do |f|
    rm_r f if File.exist? f
  end
end

namespace :gem do
  desc 'Build gems'
  task :build => [:clean] do
    if ENV['BUNDLE_GEMFILE']
      STDERR.puts 'This command will fail if run via bundler. If you are using RVM, please try running the following command:'
      STDERR.puts "  NOEXEC_DISABLE=1 #{File.basename($0)} #{ARGV.join(' ')}"
      exit 1
    end

    mkdir 'pkg' unless File.exist? 'pkg'
    platforms.each do |p|
      ENV['BUILD_PLATFORM'] = p
      sh *%w{gem build usmu.gemspec}
    end
    Dir['*.gem'].each do |gem|
      mv gem, "pkg/#{gem}"
    end
  end

  desc 'Install gem'
  task :install => ['gem:build'] do
    if RUBY_PLATFORM == 'java'
      sh *%W{gem install pkg/usmu-#{Usmu::VERSION}-java.gem}
    else
      sh *%W{gem install pkg/usmu-#{Usmu::VERSION}.gem}
    end
  end

  desc 'Deploy gems to rubygems'
  task :deploy => ['gem:build'] do
    current_gems.each do |gem|
      sh *%W{gem push #{gem}}
    end
    sh *%W{git tag #{Usmu::VERSION}} if File.exist? '.git'
  end
end

# (mostly) borrowed from: https://gist.github.com/mcansky/802396
desc 'generate changelog with nice clean output'
task :changelog, :since_c, :until_c do |t,args|
  since_c = args[:since_c] || `git tag | egrep '^[0-9]+\\.[0-9]+\\.[0-9]+\$' | sort -Vr | head -n 1`.chomp
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
