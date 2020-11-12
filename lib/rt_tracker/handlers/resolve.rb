require 'dry/effects'

module RtTracker
  module Handlers
    class Resolve
      include ::Dry::Effects::Handler.Resolve
      include Import['env.test']

      def call
        provide(App, overridable: test) { @app.(env) }
      end
    end
  end
end
