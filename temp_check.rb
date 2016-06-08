$LOAD_PATH.unshift("/home/pi/wemote-0.2.2/lib")
require "wemote"
require "csv"

filename = "w1_slave"
sensor_id = `ls /sys/bus/w1/devices/`.split("\n").first

ac_device = Wemote::Switch.find("Air Conditioner")

while true
  file = File.new("/sys/bus/w1/devices/#{sensor_id}/#{filename}", "r")
  read_file = file.read.split("\n")
  c_temp = read_file.last.split("t=").last.to_f/1000
  f_temp = c_temp * 1.8 + 32
  human_f_temp = f_temp.round(2)


  if f_temp > 75 && ac_device.off?
    puts "Turning Air Conditioner on because it's #{human_f_temp}"
    ac_device.on!
  elsif f_temp < 73 && ac_device.on?
    puts "Turning Air Conditioner off because it's #{human_f_temp}"
    ac_device.off!
  else
    puts "It's #{human_f_temp} so the AC should stay #{ac_device.on? ? "on" : "off"}"
  end

  CSV.open("./tmp_log.csv", "ab") do |csv|
    csv << [Time.now.to_s, human_f_temp]
  end

  sleep 10
end
