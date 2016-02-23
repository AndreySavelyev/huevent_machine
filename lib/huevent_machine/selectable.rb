module HueventMachine
  class Selectable
    attr_reader :io, :blk

    def initialize(io, blk)
      @io = io
      @blk = blk
    end
  end
end
