# auto_register: false

require 'logger'
require 'dry/events/publisher'
require 'dry/effects'
require 'dry/struct'

module RtTracker
  class TaggedLogger
    include ::Dry::Events::Publisher[:logger]
    include ::Dry::Effects.Reader(:logger, as: :tags)
    include ::Dry::Effects::Handler.Reader(:logger, as: :with_tags)

    class << self
      include ::Dry::Effects::Handler.Reader(:logger, as: :with_tags)

      def call(&block)
        with_tags(EMPTY_ARRAY, &block)
      end
    end

    EVENT_ID = 'logger.message'

    register_event(EVENT_ID)

    LevelMap = ::Logger::Severity.constants(false).each_with_object({}) do |constant, h|
      num = ::Logger::Severity.const_get(constant)
      h[num] = constant.to_s.downcase.to_sym
    end

    def initialize
      super
      __bus__
    end

    def call(level, message = Undefined, payload = EMPTY_HASH, &block)
      extra_tags = payload.fetch(:tags, EMPTY_ARRAY)
      publish(
        EVENT_ID,
        {
          message: message,
          message_proc: block,
          level: level,
          **payload,
          tags: tags | extra_tags
        }
      )
    end

    def log(severity, message = Undefined, &block)
      self.(LevelMap.fetch(severity), message, &block)
    end

    def subscribe(options = EMPTY_HASH, &block)
      super(EVENT_ID, options, &block)
    end

    %i(debug info warn error fatal).each do |level|
      define_method(level) do |message = Undefined, payload = EMPTY_HASH, &block|
        self.(level, message, payload, &block)
      end
    end

    def [](*tags, &block)
      tagged(*tags, &block)
    end

    def tagged(*new_tags, &block)
      with_tags(tags | new_tags, &block)
    end
  end
end
