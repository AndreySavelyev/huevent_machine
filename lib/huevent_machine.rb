require 'socket'

class HueventMachine
  def initialize(addr, port, handler)
    @addr, @port = addr, port
    @handler = handler
  end

  def run
    puts 'AAAAAAAAAAAAAAAAAAAAAAAAAAAa4'
    @server = Class.new
    @server.include @handler
    puts 'AAAAAAAAAAAAAAAAAAAAAAAAAAAa3'

    @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    @addrinfo = Addrinfo.tcp(@addr, @port)
    @socket.bind(@addrinfo)
    @socket.listen(5)

    puts 'AAAAAAAAAAAAAAAAAAAAAAAAAAAa'
  end

  def self.start_server address, port, handler
    puts 'AAAAAAAAAAAAAAAAAAAAAAAAAAAa1'
    server = new(address, port, handler)
    server.run
    puts 'AAAAAAAAAAAAAAAAAAAAAAAAAAAa2'
  end
end
