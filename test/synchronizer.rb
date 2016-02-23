class Synchronizer
  module ClassMethods
    attr_reader :m, :cv

    def init!
      @m = Mutex.new
      @cv = ConditionVariable.new
    end

    def wait
      puts ">>>>>>> WAIT"
      m.synchronize { cv.wait(m) }
    end

    def pass
      puts ">>>>>>> PASS"
      m.synchronize { cv.signal }
    end
  end

  extend ClassMethods
  init!
end
