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
    end

    config.inflector = ::Dry::Inflector.new do
      _1.acronym('API', 'COVID19')
    end

    load_paths!(*[
      ::File.expand_path("#{root}/lib"),
      ::File.expand_path("#{root}/app"),
    ])
  end

  Import = App.injector(dynamic: App[:env].eql?('test'))
end

require_relative 'boot/logger'
