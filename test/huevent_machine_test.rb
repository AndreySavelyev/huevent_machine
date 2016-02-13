require "minitest/autorun"
require "huevent_machine"
require "socket"


class TestHueventMachine < Minitest::Test
  module EchoServer
    def post_init
    end
  end

  def setup
    @addr = '127.0.0.1'
    @port = rand(2224..2999)
    @handler = EchoServer
    @machine = HueventMachine.new(@addr, @port, @handler)
  end

  def test_instance
    assert @machine
  end

  def test_start_server
    child_id = Process.fork do
      HueventMachine.start_server(@addr, @port, @handler)

      server = new(address, port, handler)
    server.run

    end

    sleep 2

    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    addrinfo = Socket.pack_sockaddr_in(@port, @addr)
    assert_equal socket.connect(addrinfo), 0

    socket.close
    Process.wait

  end

end
