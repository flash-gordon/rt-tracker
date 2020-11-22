require 'net/http'
require 'openssl'
require 'dry/monads'
require 'dry/effects'

module RtTracker
  class HTTPCall
    include ::Dry::Monads[:try, :result]
    include ::Dry::Effects.Timestamp
    include ::Dry::Effects.Timeout(:http)

    METHODS = {
      get: ::Net::HTTP::Get,
      post: ::Net::HTTP::Post,
      patch: ::Net::HTTP::Patch,
      delete: ::Net::HTTP::Delete,
    }.freeze

    Errors = [
      ::SocketError,
      ::SystemCallError,
      ::Timeout::Error,
      ::EOFError,
      ::IOError,
      ::Net::OpenTimeout,
      ::Net::HTTPBadResponse,
      ::Net::HTTPHeaderSyntaxError,
      ::Net::ProtocolError,
      ::OpenSSL::SSL::SSLError,
      ::URI::InvalidURIError
    ]

    include Import[
      'env.development',
      'env.test',
      'logger'
    ]

    def call(url:, method:, headers: EMPTY_HASH, body: Undefined, log: EMPTY_HASH, **options)
      raise ::RuntimeError, "HTTP calls in test environmnt are not allowed!" if test
      start = timestamp
      byebug
      Try[*Errors] { perform(url, method, headers, body, **options) }.to_result.tap do
        log(log, start, url, method, headers, body, _1)
      end
    end

    def perform(url, method, headers, body, timeout: self.timeout, basic_auth: Undefined)
      uri = URI(url)

      options = {
        use_ssl: uri.scheme.eql?('https'),
        open_timeout: timeout,
        read_timeout: timeout
      }

      ::Net::HTTP.start(uri.host, uri.port, options) do |http|
        request = METHODS.fetch(method.to_sym).new(uri)

        headers.each do |key, value|
          request[key.to_s] = value
        end

        request.basic_auth(*basic_auth) unless Undefined.equal?(basic_auth)
        request.body = body unless Undefined.equal?(body)

        response = http.request(request)

        code = Integer(response.code, 10)
        headers = response.each_capitalized.each_with_object({}) do |(k, v), h|
          h[k] ||= []
          h[k] << v
        end
        body = response.body

        [code, headers, body]
      end
    end

    def log(what, start, url, method, headers, body, result)
      duration = (timestamp.to_f - start.to_f).round(3)

      if development
        level = :info
      else
        level = result.success? ? :debug : :info
      end

      logger.tagged("http-#{next_request_id}") do
        logger.(level) do
          "HTTP #{method.to_s.upcase} #{url} "\
          "headers: #{headers.inspect} "\
          "body: #{body.inspect}"
        end

        case result
        in Success[code, headers, body]
          logger.(level) do
            "Response(#{duration}s), "\
            "status: #{code}, "\
            "headers: #{headers.inspect}, "\
            "body: #{what.fetch(:response_body, true) ? body.inspect : '<skipped>'}"
          end
        in Failure(exception)
          logger.(level) do
            "Failed(#{duration}s). Reason: #{exception.message}"
          end
        end
      end
    end

    def next_request_id
      (timestamp.to_f * 1000).to_i
    end
  end
end
