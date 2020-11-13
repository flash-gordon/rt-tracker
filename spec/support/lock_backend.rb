module LockBackend
  Failing = Class.new {
    def lock(_, _)
      nil
    end
  }.new

  Succeeding = Class.new {
    def lock(_, _)
      true
    end

    def unlock(_)
      true
    end
  }.new

  class Chain
    attr_reader :sequence

    def initialize(*sequence)
      @sequence = sequence
    end

    def lock(_, _)
      sequence.shift
    end
  end
end
