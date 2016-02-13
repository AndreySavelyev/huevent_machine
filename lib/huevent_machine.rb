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
      unbind
    end

    def unbind
      # implement
    end

    def post_init
      # implement
    end
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

      break unless @@run
      next unless ready

      ready[0].each do |io|
        if server.socket == io # server socket
          puts "New client" #* 30
          client, client_addrinfo = io.accept
          handler = server.handler.new(client, client_addrinfo)
          @@clients ||= []
          @@clients << handler
          handler.post_init
          @@client_sockets << handler.socket
        else # client socket
          #puts
          str = io.gets

          if str.nil?
            puts "Closed connection: #{io.inspect}"
            #server = @@servers.find { |s| s.socket == io }
            handler = @@clients.find { |c| c.socket == io }
            handler.close
            @@client_sockets.delete(handler.socket)
          else
            # TODO: receive_data
          end
        end
      end
    end

    clear
  #rescue Exception => e
  #  binding.pry
  end

  def self.clear
    puts 'CLEAR' * 10
    @@client_sockets.each(&:close)
    @@client_sockets = []
    @@servers.each(&:stop)
    @@servers = []
  end

  def self.stop
    puts "STOP SIGNAL"
    @@run = false
  end

  def self.start_server address, port, handler
    @@client_sockets ||= []
    @@servers ||= []

    server = BaseServer.new(address, port, handler)
    server.listen

    @@servers << server
  end
end
