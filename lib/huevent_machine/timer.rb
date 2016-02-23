module HueventMachine
  class Timer
    attr_reader :time, :blk

    def initialize(time, blk)
      @time = time
      @blk = blk
    end
  end
end
