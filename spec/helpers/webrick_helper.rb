require 'webrick'
require 'null_logger'

module WEBrickHelper
  def port
    52195
  end

  def server
    @server ||= ::WEBrick::HTTPServer.new(
      Port: port,
      Logger: ::NullLogger.new,
      AccessLog: ::NullLogger.new
    )
  end

  def caught_requests
    @caught_requests ||= []
  end

  def run_server
    thread = ::Thread.new { server.start }
    sleep(0.05)
    yield
  ensure
    server.stop
    thread.join
  end
end
