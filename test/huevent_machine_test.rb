require "minitest/autorun"
require 'huevent_machine'


class TestHueventMachine < Minitest::Test
  def setup
    @addr = 'localhost'
    @port = 2222
    @handler = EchoServer
    @machine = HueventMachine.new(@addr, @port, @handler)
  end

  def test_instance
    assert @machine
  end

  def test_start_server
    assert @machine.start_server(@address, @port, @handler)
  end

end
