$LOAD_PATH.unshift File.dirname(__FILE__)

require "minitest/autorun"
require "huevent_machine"
require 'pry'
require "socket"
require "synchronizer"

class TestHueventMachine < Minitest::Test
  module TestServer
    def post_init
      puts "POST INIT!" * 10
      Thread.current[:post_init_received] = true

      puts "pass sync2"
      Synchronizer.pass
    end

    def receive_data(data)
    end

    def unbind
      puts "UNBIND" * 30
      HueventMachine.stop
    end
  end

  def setup
    @addr = '127.0.0.1'
    @port = rand(2224..2999)
    @handler = TestServer
  end

  def xtest_start_server
    puts " >>>>>>>>>>>>>>>>>>>>>>>>>>> test_start_server"
    HueventMachine.start_server(@addr, @port, Module.new)

    assert_equal HueventMachine.class_variable_get(:@@servers).size, 1

    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    addrinfo = Socket.pack_sockaddr_in(@port, @addr)
    assert_equal socket.connect(addrinfo), 0
    socket.close
    HueventMachine.clear
  end

  def test_run
    puts " >>>>>>>>>>>>>>>>>>>>>>>>>>> test_run"

    thread = Thread.new do
      HueventMachine.run do
        HueventMachine.start_server(@addr, @port, @handler)
      end

      puts "pass sync1"
      Synchronizer.pass
    end

    #sleep 1
    puts "wait sync1"
    Synchronizer.wait

    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    addrinfo = Socket.pack_sockaddr_in(@port, @addr)
    socket.connect(addrinfo)
    puts "wait sync2"
    Synchronizer.wait
    assert_equal thread[:post_init_received], true

    socket.close

    HueventMachine.stop
  end

end
