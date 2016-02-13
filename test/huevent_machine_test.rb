require "minitest/autorun"
require "huevent_machine"
require "socket"


class TestHueventMachine < Minitest::Test
  module EchoServer
    def post_init
    end

    def unbind
      stop
    end
  end

  def setup
    @addr = '127.0.0.1'
    @port = rand(2224..2999)
    @handler = EchoServer
  end

  def test_start_server
    server = HueventMachine.start_server(@addr, @port, @handler)

    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    addrinfo = Socket.pack_sockaddr_in(@port, @addr)
    assert_equal socket.connect(addrinfo), 0
    assert_equal server.class_variable_get('@@servers'), 1
    socket.close

  end

end
