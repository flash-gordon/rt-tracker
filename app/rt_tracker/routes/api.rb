require 'roda'
require 'rt_tracker/middleware/resolve'
require 'rt_tracker/middleware/logger'
require 'rt_tracker/middleware/timestamp'

module RtTracker
  module Routes
    class API < ::Roda
      use Middleware::Resolve
      use Middleware::Logger
      use Middleware::Timestamp

      route do |r|
        r.on('numbers') { r.run(NumberAPI) }
      end
    end
  end
end
