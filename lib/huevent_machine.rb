require 'socket'

class HueventMachine
  module BaseServer
    def initialize(addr, port)
      @addr = addr
      @port = port
    end

    def listen
      @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
      addrinfo = Addrinfo.tcp(@addr, @port)
      @socket.bind(addrinfo)
      @socket.listen(5)
    end

    def stop
      @socket.close
    end
  end

  def self.run
    yield

    server = @@servers.first
    @clients = []
    loop do
      puts 'wait accept' * 30
      read_sockets = @clients + [server.socket]
      ready = IO.select(read_sockets, [], [])

      puts "*"*100
      puts ready

      ready[0].each do |io|
        if io == server.socket # server socket
          puts "New client" * 30
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

  rescue Errno::ECONNRESET => e
    binding.pry
  end

  def self.stop
    puts "STOP SIGNAL"
    @@servers.each(&:stop)
    @@servers = []
  end

  def self.start_server address, port, handler
    @@servers ||= []

    server_class = Class.new
    server_class.include BaseServer
    server_class.include handler
    handle = server_class.new(address, port)

    handle.listen

    @@servers << handle
  end
end
