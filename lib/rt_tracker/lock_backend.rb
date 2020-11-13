require 'securerandom'
require 'json'
require 'dry/effects'

module RtTracker
  # Lock-effect compatible implementation
  class LockBackend
    include ::Dry::Effects.Reader(:lock_meta)

    include KwargsImport[
      'fun.hash64',
      'redis',
      lock_manager: 'redlock'
    ]

    EXPIRES_IN_MS = 60_000

    def initialize(**)
      super
      @meta_prefix = ::SecureRandom.hex
    end

    def lock(key, meta = Undefined)
      expires_in = EXPIRES_IN_MS
      key = key(key)
      handle = lock_manager.lock(key, expires_in)

      if Undefined.equal?(meta)
        handle || nil
      elsif handle
        redis.with do
          _1.set(meta_key(key), ::JSON.dump(meta), px: expires_in)
        end
        handle
      else
        nil
      end
    end

    def locked?(key)
      locked = lock(key)
      unlock(locked) if locked
      locked.nil?
    end

    def unlock(handle)
      lock_manager.unlock(handle)
    end

    def meta(key)
      value = redis.with { _1.get(meta_key(key(key))) }
      ::JSON.parse(value, symbolize_names: true) if value
    end

    def key(key)
      hash64.(*Array(key))
    end

    def meta_key(key)
      "#{@meta_prefix}:#{key}"
    end
  end
end
