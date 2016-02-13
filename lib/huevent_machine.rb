require 'socket'

class HueventMachine
  module BaseServer
    attr_reader :addr
    attr_reader :port
    attr_reader :socket

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

    def unbind
    end
  end

  def self.run
    @@run = true

    yield

    server = @@servers.first
    @@clients ||= []

    loop do
      puts 'wait accept' #* 30
      read_sockets = @@clients + @@servers.map(&:socket)
      puts 'select'
      ready = IO.select(read_sockets, [], [], 1)

      puts "ready" #* 100
      puts ready.inspect
      puts "run: #{@@run}"

      if ready.nil?
        break unless @@run
      else
        ready[0].each do |io|
          if @@servers.find { |server| server.socket == io } # server socket
            puts "New client" #* 30
            client, client_addrinfo = io.accept
            @@clients << client
            server.post_init
          else # client socket
            puts
            str = io.gets

            if str.nil?
              puts "Closed connection: #{io.inspect}"
              #server = @@servers.find { |s| s.socket == io }
              server.unbind
              io.close
              @@clients.delete(io)
            elsif str == "exit\n"
              puts "Exi command from: #{io.inspect}"
              io.close
              @@clients.delete(io)
            else
              puts "Client: #{str}"
            end
          end
        end
      end
    end


  end

  def self.stop
    puts "STOP SIGNAL"
    @@servers.each(&:stop)
    @@servers = []

    @@run = false
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
