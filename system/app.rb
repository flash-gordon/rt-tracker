ENV['TZ'] = 'UTC'

require 'dry/core/inflector'
require 'dry/inflector'
Dry::Core::Inflector.select_backend(:dry_inflector)

require 'dry/validation'
Dry::Schema.load_extensions(:monads)
Dry::Validation.load_extensions(:monads)

require 'dry/effects'
Dry::Effects.load_extensions(:system)

require_relative 'app/loader'

module RtTracker
  class App < ::Dry::Effects::System::Container
    config.loader = Loader
    config.default_namespace = 'rt_tracker'
    config.root = ::File.expand_path(::File.join(__dir__, '../..'))

    load_paths!(*[
      ::File.expand_path("#{root}/lib"),
      ::File.expand_path("#{root}/app"),
      ::File.expand_path("#{__dir__}/..")
    ])
  end

  Import = injector(dynamic: App[:env].eql?('test'))
end
