class Synchronizer
  module ClassMethods
    attr_reader :m, :cv

    def init!
      @m = Mutex.new
      @cv = ConditionVariable.new
    end

    def wait
      m.synchronize { cv.wait(m) }
    end

    def pass
      m.synchronize { cv.signal }
    end
  end

  extend ClassMethods
  init!
end
