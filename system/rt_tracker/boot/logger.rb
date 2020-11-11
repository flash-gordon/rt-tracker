require 'dry/core/constants'

RtTracker::App.boot(:logger) do |app|
  init do
    require 'rt_tracker/tagged_logger'

    if app['env.test']
      require 'stringio'
      register(:log_output, StringIO.new)
    else
      register(:log_output, $stdout)
    end

    register(:logger, RtTracker::TaggedLogger.new.freeze)
  end

  start do
    output = ::Logger.new(app['log_output'])
    log = proc do |event|
      payload = event.payload
      tags = payload.fetch(:tags).map { "[#{_1}]" }.join(' ')
      level = payload.fetch(:level)

      message = payload.fetch(:message)

      output.public_send(level) do
        if Dry::Core::Constants::Undefined.equal?(message)
          "#{tags} #{payload.fetch(:message_proc).()}"
        else
          "#{tags} #{message}"
        end
      end
    end

    logger.subscribe(level: %i(debug info warn error fatal), &log)
  end
end
