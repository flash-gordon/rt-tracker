require 'rt_tracker/http_call'

RSpec.describe RtTracker::HTTPCall, :webrick do
  subject(:http_call) { described_class.new }

  before { deps['env.test'] = false }

  it 'sends a request' do
    server.mount_proc '/' do |req, _|
      caught_requests << [req.request_uri, req.header, req.body]
    end

    run_server do
      http_call.(
        url: "http://localhost:#{port}/",
        headers: { 'Content-Type' => 'plain/text' },
        method: 'post',
        body: 'test'
      )
    end

    expect(caught_requests.size).to eql(1)

    _, headers, body = caught_requests.first

    expect(body).to eql('test')
    expect(headers).to include(
      'accept' => ['*/*'],
      'accept-encoding' => ['gzip;q=1.0,deflate;q=0.6,identity;q=0.3'],
      'content-length' => ['4'],
      'content-type' => ['plain/text'],
      'host' => ['localhost:52195'],
      'user-agent' => ['Ruby']
    )
  end

  describe 'errors' do
    it 'catches a SocketError' do
      result = http_call.(
        url: 'http://fake.url/',
        method: 'post',
        headers: {
          'Content-Type' => 'plain/text'
        }
      )

      expect(result).to be_a_failure

      error = result.failure

      expect(error).to be_a(SocketError)
    end

    it 'catches ECONNREFUSED/EADDRNOTAVAIL' do
      error = http_call.(
        url: 'such',
        method: 'post',
        headers: {
          'Content-Type' => 'plain/text'
        }
      ).failure

      expect([Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL]).to include(error.class)
    end

    it 'catches timeout' do
      server.mount_proc '/' do |req, res|
        sleep 0.6
      end

      error = run_server do
        http_call.(
          url: "http://localhost:#{port}/",
          method: 'post',
          timeout: 0.3,
          headers: {
            'Content-Type' => 'plain/text'
          }
        ).failure
      end

      expect(error).to be_a(Timeout::Error)
    end
  end

  it 'wotks with https' do
    result = http_call.(
      url: 'https://google.com/',
      method: 'get',
      headers: {
        'Content-Type' => 'plain/text'
      }
    )

    expect(result).to be_a_success
  end
end
