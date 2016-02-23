require 'test_helper'
require 'huevent_machine/reactor'
require 'stringio'
require 'support/synchronizer'

module HueventMachine
  class ReactorTest < Minitest::Test
    def setup
      @reactor = Reactor.new
    end

    def test_add_timer
      @reactor.add_timer(10) {}
      assert_equal 1, @reactor.timers.size
    end

    def test_add_readable
      readable = StringIO.new
      @reactor.add_readable(readable) {}
      assert_equal 1, @reactor.readables.size
    end

    def test_run
      readable = StringIO.new
      @reactor.add_readable(readable) {}
      @reactor.on_start { Synchronizer.pass }
      thread = Thread.new { @reactor.run }
      Synchronizer.wait
      assert_equal true, @reactor.running?
    end
  end
end
