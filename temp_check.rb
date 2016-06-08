$LOAD_PATH.unshift("/home/pi/wemote-0.2.2/lib")
require "wemote"
require "csv"
require "./lib/temp_sensor.rb"
#require "wolfram_databin"

sensor_serial = `ls /sys/bus/w1/devices/`.split("\n").first

ac_device = Wemote::Switch.find("Air Conditioner")

threshold = 0.5
target_temp = 75.0

while true
  sensor = TempSesor.new(sensor_serial)
  temp = sensor.temp

  human_temp = temp.round(0)

  puts "Target Temp: #{target_temp}"
  puts "Current Temp: #{human_temp}º"
  puts "****************************"

  if temp > (target_temp + threshold) && ac_device.off?
    puts "Turning A/C on"
    ac_device.on!
  elsif temp < (target_temp - threshold) && ac_device.on?
    puts "Turning A/C off"
    ac_device.off!
  end

  CSV.open("./tmp_log.csv", "ab") do |csv|
    csv << [Time.now.to_s, human_temp]
  end

  sleep 10
end
