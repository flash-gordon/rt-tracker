# auto_register: false

require 'dry/effects'

module RtTracker
  module Middleware
    class Timestamp
      include ::Dry::Effects::Handler.Timestamp
      include Import['env.test']

      def initialize(app)
        @app = app
      end

      def call(env)
        with_timestamp(overridable: test) { @app.(env) }
      end
    end
  end
end
