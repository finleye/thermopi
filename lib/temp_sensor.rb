class TempSensor
  FILENAME = "w1_slave".freeze

  attr_accessor :serial

  def initialize(serial)
    @serial = serial
  end

  def temp
    file = File.new("/sys/bus/w1/devices/#{serial}/#{FILENAME}", "r")
    read_file = file.read.split("\n")
    c_temp = read_file.last.split("t=").last.to_f/1000
    c_temp * 1.8 + 32
  end
end
