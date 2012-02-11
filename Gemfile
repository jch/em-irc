source 'http://rubygems.org'

# Specify your gem's dependencies in em-irc.gemspec
gemspec

group :development do
  gem 'pry'
  gem 'yard'
  gem 'redcarpet'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group :development, :test do
  gem 'rake'
  gem 'rspec', "~> 2"
end

group :darwin do
  gem 'rb-fsevent'
  gem 'growl'
end