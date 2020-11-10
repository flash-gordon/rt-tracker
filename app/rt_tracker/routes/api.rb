require 'roda'

module RtTracker
  module Routes
    class API < ::Roda
      route do |r|
        r.on('numbers') { r.run(NumberAPI) }
      end
    end
  end
end
