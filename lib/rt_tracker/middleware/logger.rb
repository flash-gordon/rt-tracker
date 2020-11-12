# auto_register: false

require 'dry/effects'
require 'rt_tracker/tagged_logger'

module RtTracker
  module Middleware
    class Logger
      def initialize(app)
        @app = app
      end

      def call(env)
        TaggedLogger.() { @app.(env) }
      end
    end
  end
end
