# auto_register: false

require 'dry/effects'

module RtTracker
  module Middleware
    class Resolve
      include ::Dry::Effects::Handler.Resolve
      include Import['env.test']

      def initialize(app)
        @app = app
      end

      def call(env)
        provide(App, overridable: test) { @app.(env) }
      end
    end
  end
end
