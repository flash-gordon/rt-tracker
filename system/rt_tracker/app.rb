ENV['TZ'] = 'UTC'

require 'dry/core/inflector'
require 'dry/inflector'
Dry::Core::Inflector.select_backend(:dry_inflector)

require 'dry/core/constants'
require 'dry/validation'
Dry::Schema.load_extensions(:monads)
Dry::Validation.load_extensions(:monads)

require 'dry/effects'
Dry::Effects.load_extensions(:system)

require_relative 'app/loader'

unless ENV['RACK_ENV'].eql?('production')
  require 'dotenv'
  env_files = [".env.#{ENV['RACK_ENV']}", '.env'].select { File.exist?(_1) }
  Dotenv.load(*env_files) unless env_files.empty?
end

module RtTracker
  include ::Dry::Core::Constants

  class App < ::Dry::Effects::System::Container
    config.loader = Loader
    config.default_namespace = 'rt_tracker'
    config.root = ::File.expand_path(::File.join(__dir__, '../..'))

    register('env') { ENV['RACK_ENV'] }

    namespace('env') do
      %w(test development production).each do |env|
        register(env) { App['env'].eql?(env) }
      end

      namespace('redis') do
        register('url') { ENV['REDIS_URL'] }
      end
    end

    inflector = ::Dry::Inflector.new do
      _1.acronym('API', 'COVID19')
    end

    config.inflector = inflector

    register('inflector') { inflector }

    load_paths!(*[
      ::File.expand_path("#{root}/lib"),
      ::File.expand_path("#{root}/app"),
    ])
  end

  Import = App.injector(dynamic: App[:env].eql?('test'))
  KwargsImport = App.injector(effects: false)
end

require 'types'
require_relative 'boot/api'
require_relative 'boot/logger'
require_relative 'boot/redlock'
require_relative 'boot/redis'
