require 'socket'

class HueventMachine
  module BaseServer
    def initialize(addr, port)
      @addr = addr
      @port = port
    end

    def listen
      socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
      addrinfo = Addrinfo.tcp(@addr, @port)
      socket.bind(addrinfo)
      socket.listen(5)
    end
  end

  def self.run
    yield

    server = @@servers.first

    loop do
      puts 'wait accept'
      read_sockets = @clients + [server.socket]
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
  end

  def self.start_server address, port, handler
    @@servers ||= []


    server_class = Class.new
    server_class.include BaseServer
    server_class.include handler
    handle = server_class.new(address, port)

    handle.listen

    @@servers << handle

    self
  end
end
