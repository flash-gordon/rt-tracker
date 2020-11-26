# auto_register: false

require 'dry/effects'

module RtTracker
  module Middleware
    class Env
      include ::Dry::Effects::Handler.Env

      def initialize(app)
        @app = app
        @overridable = App['env.test']
      end

      def call(env)
        with_env(EMPTY_HASH, overridable: @overridable) { @app.(env) }
      end
    end
  end
end
