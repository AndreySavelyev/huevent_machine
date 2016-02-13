require 'socket'

class HueventMachine
  module BaseServer
    def initialize(machine)
      @machine = machine
    end
  end

  def initialize(addr, port, handler)
    @addr, @port = addr, port
    @handler_module = handler
    @server_class = Class.new
    @server_class.include BaseServer
    @server_class.include @handler_module

    @clients = []
  end

  def run
    @handle = @server_class.new(self)
    puts "RUN SERVER"
    @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    @addrinfo = Addrinfo.tcp(@addr, @port)
    @socket.bind(@addrinfo)
    @socket.listen(5)

    loop do
      puts 'wait accept'
      #client_socket, client_addrinfo = @socket.accept

      read_sockets = clients + [@socket]
      ready = IO.select(read_sockets, [], [])

      ready[0].each do |io|
        if io == socket # server socket
          puts "New client"
          client, client_addrinfo = @socket.accept
          clients << client
        elsif io == read_io
          sig = io.gets
          puts "Signal: #{sig}"
        else # client socket
          #puts "New client data"
          str = io.gets

          if str.nil?
            puts "Closed connection: #{io.inspect}"
            io.close
            clients.delete(io)
          elsif str == "exit\n"
            puts "Exi command from: #{io.inspect}"
            io.close
            clients.delete(io)
          else

            puts "Client: #{str}"
          end
        end
      end
    end
  end

  def stop
    #
  end

  def self.create_server(address, port, handler)
    new(address, port, handler)
  end

  def self.start_server address, port, handler
    server = create_server(address, port, handler)
    server.run
  end
end
