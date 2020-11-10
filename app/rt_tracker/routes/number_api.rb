require 'roda'

module RtTracker
  module Routes
    class NumberAPI < ::Roda
      route do |r|
        r.on('ping') do
          'pong'
        end
      end
    end
  end
end
