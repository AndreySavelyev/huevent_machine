class HueventMachine
  def initialize(address, port, handler)
    @address, @port = address, port
    @handler = handler.new
  end

  def self.start_server address, port, handler
    new(address, port, handler)
  end
end
