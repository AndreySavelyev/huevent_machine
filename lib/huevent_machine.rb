require 'socket'

class HueventMachine
  def initialize(addr, port, handler)
    @addr, @port = addr, port
    @handler = handler
  end

  def run
    @server = Class.new
    @server.include @handler
    puts "RUN SERVER"
    @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    @addrinfo = Addrinfo.tcp(@addr, @port)
    @socket.bind(@addrinfo)
    @socket.listen(5)

    loop do
      puts 'wait accept'
      client_socket, client_addrinfo = @socket.accept
    end
  end

  def self.start_server address, port, handler
    server = new(address, port, handler)
    server.run
  end
end
