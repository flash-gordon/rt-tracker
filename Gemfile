ruby '2.7.2'
Warning[:experimental] = false

source 'https://rubygems.org'

git_source(:github) { "https://github.com/#{_1}" }

gem 'pry-byebug'
gem 'puma'
gem 'rake'

gem 'dry-effects'
gem 'dry-monads'
gem 'dry-validation'
gem 'dry-system'

group :test do
  gem 'faker'
  gem 'null-logger', require: false
  gem 'rspec'
  gem 'super_diff'
  gem 'warning'
end
