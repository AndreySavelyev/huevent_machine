require 'socket'

class HueventMachine
  class BaseServer
    attr_reader :addr
    attr_reader :port
    attr_reader :socket
    attr_reader :handler

    def initialize(addr, port, handler_module)
      @addr = addr
      @port = port
      @handler = Class.new
      @handler.include BaseHandler
      @handler.include handler_module
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

  module BaseHandler
    attr_reader :socket

    def initialize(socket, client_addrinfo)
      @socket = socket
      @client_addrinfo = client_addrinfo
    end

    def close
      @socket.close
    end
  end

  def self.create_handler(server, client, client_addrinfo)
    @@clients ||= []
    @@clients << server.handler.new(client, client_addrinfo)
  end

  def self.run
    @@run = true

    yield

    server = @@servers.first
    @@client_sockets ||= []

    loop do
      puts 'wait accept' #* 30
      read_sockets = @@client_sockets + [server.socket]
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
            @@client_sockets << client
            handler = create_handler(server, client, client_addrinfo)
            handler.post_init
          else # client socket
            #puts
            str = io.gets

            if str.nil?
              puts "Closed connection: #{io.inspect}"
              #server = @@servers.find { |s| s.socket == io }
              client = @@clients.find { |c| c.socket == io }
              client.close
              @@clients.delete(client.socket)
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

    server = BaseServer.new(address, port, handler)
    server.listen

    @@servers << server
  end
end
