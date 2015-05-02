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

if RUBY_VERSION.to_f >= 2 && RUBY_VERSION.to_f < 2.2 && RUBY_ENGINE == 'ruby'
  gem 'mutant', '~> 0.7', :group => :development
  gem 'mutant-rspec', '~> 0.7', :group => :development
end
