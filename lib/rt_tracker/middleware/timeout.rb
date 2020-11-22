# auto_register: false

require 'dry/effects'

module RtTracker
  module Middleware
    class Timeout
      include ::Dry::Effects::Handler.Timeout
      include Import['env.test']

      def initialize(app)
        @app = app
      end

      def call(env)
        with_timeout(10.0, overridable: test) { @app.(env) }
      rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout
        [504, {}, ["Gateway Timeout"]]
      end
    end
  end
end
