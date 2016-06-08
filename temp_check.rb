$LOAD_PATH.unshift("/home/pi/wemote-0.2.2/lib")
require "wemote"
require "csv"
require "./lib/temp_sensor.rb"
#require "wolfram_databin"

sensor_serial = `ls /sys/bus/w1/devices/`.split("\n").first

ac_device = Wemote::Switch.find("Air Conditioner")

while true
  sensor = TempSesor.new(sensor_serial)
  temp = sensor.temp

  human_temp = temp.round(2)

  if temp > 75 && ac_device.off?
    puts "Turning Air Conditioner on because it's #{human_temp}"
    ac_device.on!
  elsif temp < 73 && ac_device.on?
    puts "Turning Air Conditioner off because it's #{human_temp}"
    ac_device.off!
  else
    puts "It's #{human_temp} so the AC should stay #{ac_device.on? ? "on" : "off"}"
  end

  CSV.open("./tmp_log.csv", "ab") do |csv|
    csv << [Time.now.to_s, human_temp]
  end

  sleep 10
end
