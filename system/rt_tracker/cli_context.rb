require 'dry/effects'

module RtTracker
  class CLIContext
    include ::Dry::Effects::Handler.Timeout(:http)

    def `(key)
      App[key]
    end
  end
end
