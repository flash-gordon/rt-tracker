require 'roda'
require 'rt_tracker/middleware/env'
require 'rt_tracker/middleware/resolve'
require 'rt_tracker/middleware/logger'
require 'rt_tracker/middleware/timeout'
require 'rt_tracker/middleware/timestamp'

require 'rt_tracker/api/middleware/authenticate'

module RtTracker
  module Routes
    class API < ::Roda
      use Middleware::Env
      use Middleware::Resolve
      use Middleware::Logger
      use Middleware::Timeout
      use Middleware::Timestamp

      use ::RtTracker::API::Middleware::Authenticate

      route do |r|
        r.on('numbers') { r.run(NumberAPI) }
      end
    end
  end
end
