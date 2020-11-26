# auto_register: false

require 'dry/effects'

module RtTracker
  module Middleware
    class Timeout
      include ::Dry::Effects::Handler.Timeout(:http)

      def initialize(app)
        @app = app
      end

      def call(env)
        with_timeout(5.0) { @app.(env) }
      end
    end
  end
end
