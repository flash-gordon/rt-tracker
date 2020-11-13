require 'digest/md5'

module RtTracker
  module Fun
    class Hash64
      def call(*args)
        md5 = ::Digest::MD5.new
        args.each { md5 << _1.to_s }
        md5.hexdigest[..8].unpack('Q')[0]
      end
    end
  end
end
