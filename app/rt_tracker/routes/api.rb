require 'roda'
require 'rt_tracker/middleware/resolve'

module RtTracker
  module Routes
    class API < ::Roda
      use Middleware::Resolve

      route do |r|
        r.on('numbers') { r.run(NumberAPI) }
      end
    end
  end
end
