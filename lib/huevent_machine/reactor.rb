require 'huevent_machine/timer'
require 'huevent_machine/selectable'

module HueventMachine
  class Reactor
    attr_reader :timers, :readables, :running

    alias_method :running?, :running

    NOOP = -> {}

    def initialize
      @timers = []
      @readables = []
      @on_start = NOOP
      @running = false
    end

    def add_timer(time, &blk)
      @timers << Timer.new(time, blk)
    end

    def add_readable(io, &blk)
      @readables << Selectable.new(io, blk)
    end

    def run
      return if running?

      @running = true
      @on_start.call

      loop do

      end
    end

    def on_start(&blk)
      @on_start = blk
    end
  end
end
