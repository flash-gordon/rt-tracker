require 'rt_tracker/lock_backend'

RSpec.describe RtTracker::LockBackend do
  let(:redlock) do
    require 'redlock'
    Redlock::Client.new([`env.redis.url`], retry_count: 1)
  end

  subject(:backend) { described_class.new(lock_manager: redlock) }

  let(:key) { rand(1..100_500) }

  it 'sets a lock' do
    handle = backend.lock(key)

    expect(handle).not_to be_nil
    expect(backend.locked?(key)).to be(true)

    backend.unlock(handle)

    expect(backend.locked?(key)).to be(false)
  end

  it 'sets meta' do
    handle = backend.lock(key, foo: 'bar')
    expect(backend.meta(key)).to eql(foo: 'bar')
    backend.unlock(handle)
  end
end
