class TempSensor
  FILE_NAME = "w1_slave".freeze

  attr_accessor :sensor_serial

  def initialize(sensor_serial)
    @sensor_serial = sensor_serial
  end

  def temp
    file = File.new("/sys/bus/w1/devices/#{sensor_serial}/#{FILE_NAME}", "r")
    read_file = file.read.split("\n")
    c_temp = read_file.last.split("t=").last.to_f/1000

    c_temp * 1.8 + 32
  end
end
