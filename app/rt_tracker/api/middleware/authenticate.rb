# auto_register: false

module RtTracker
  module API
    module Middleware
      class Authenticate
        include Import['api.request_authenticated']

        def initialize(app)
          @app = app
        end

        def call(env)
          if request_authenticated.(env)
            @app.(env)
          else
            [403, {}, ['Not authorized']]
          end
        end
      end
    end
  end
end
