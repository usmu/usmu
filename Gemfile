source 'https://rubygems.org'

unless ENV['BUILD_PLATFORM']
  ENV['BUILD_PLATFORM'] = case RUBY_ENGINE
                            when 'ruby'
                              'ruby'
                            when 'jruby'
                              'java'
                            else
                              nil
                          end
end

# Specify your gem's dependencies in usmu.gemspec
gemspec name: 'usmu'

gem 'codeclimate-test-reporter', group: :test, require: nil

if RUBY_VERSION.to_f >= 2 && RUBY_VERSION.to_f < 2.2 && RUBY_ENGINE == 'ruby'
  gem 'mutant', '~> 0.7'
  gem 'mutant-rspec', '~> 0.7'
end
