source 'https://rubygems.org'

unless ENV['BUILD_PLATFORM']
  ENV['BUILD_PLATFORM'] = case RUBY_ENGINE
                            when 'jruby'
                              'java'
                            else
                              'ruby'
                          end
end

# Specify your gem's dependencies in usmu.gemspec
gemspec name: 'usmu'

gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'mutant', '~> 0.8', group: 'mutant'
gem 'mutant-rspec', '~> 0.8', group: 'mutant'
