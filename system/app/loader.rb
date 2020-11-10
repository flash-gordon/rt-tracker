require 'dry/system/loader'

module RtTracker
  class Loader < ::Dry::System::Loader
    def call(...)
      if singleton?(constant)
        constant.instance(...)
      else
        @component ||= constant.new.freeze
      end
    rescue => e
      raise ::LoadError, "Cannot instantiate #{constant}\n#{e.full_message}", e.backtrace
    end
  end
end
