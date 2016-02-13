#!/usr/bin/env ruby

require 'pry'
require 'socket'

socket = Socket.new(:INET, :STREAM)
socket.bind(Addrinfo.tcp("127.0.0.1", 2222))

socket.listen(5)

clients = []

puts 'Listening post 2222'

loop do
  ra = [socket] + clients
  ready = IO.select(ra, [], [])
  ready[0].each do |io|
    if socket == io
      client_socket, client_addrinfo = socket.accept
      clients << client_socket
      puts 'Accept'
    else
      puts 'Data received'
      payload = io.gets
      if payload
        data = payload.chomp
        if data == 'q'
          io.close
        elsif data == 'd'
          binding.pry
        else
          io.puts data.reverse
        end
      else
        io.close
      end
    end
  end
end
