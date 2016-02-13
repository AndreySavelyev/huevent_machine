require "minitest/autorun"
require "huevent_machine"
require "socket"


class TestHueventMachine < Minitest::Test
  module EchoServer
    def post_init
    end
  end

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
    child_id = Process.fork do
      puts 'qweqweeeeeeeeeeeeeeee'
      puts @address
      puts @port
      puts @address
      @machine.start_server(@address, @port, @handler)
      puts 'qweqweeeeeeeeeeeeeeee2'
    end

    socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    addrinfo = Socket.pack_sockaddr_in(@port, @addr)
    assert_equal socket.connect(addrinfo), 0

    Process.wait
  end

end
