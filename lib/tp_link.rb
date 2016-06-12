require "socket"
class TpLink
  PORT = 9999
  attr_accessor :ip_address

  def initialize(ip)
    @ip_address = ip
  end

  def on?; true; end
  def off?; true; end

  def on!
    data = ["0000002ad0f281f88bff9af7d5ef94b6c5a0d48bf99cf091e8b7c4b0d1a5c0e2d8a381f286e793f6d4eedfa2dfa2"].pack("H*")
    TCPSocket.new(ip_address, PORT).write(data)
  end

  def off!
    data = ["0000002ad0f281f88bff9af7d5ef94b6c5a0d48bf99cf091e8b7c4b0d1a5c0e2d8a381f286e793f6d4eedea3dea3"].pack("H*")
    TCPSocket.new(ip_address, PORT).write(data)
  end
end
