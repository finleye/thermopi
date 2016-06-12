require "./lib/thermostat.rb"

living_room_sensor = "28-000002e37be8"
bedroom_sensor = "28-03164016a6ff"

puts "Setting up bedroom switch"
bedroom_switch_mac_partial = "4b:e3"
bedroom_switch_ip = IpFinder.find(bedroom_switch_mac_partial).first
bedroom_switch = TpLink.new(bedroom_switch_ip)

puts "Setting up living room switch"
living_room_mac_partial = "90:ad"
living_room_switch = Wemote::Switch.all(living_room_mac_partial).first

puts "Creating zones"
living_room_zone = LivingRoom.new(living_room_sensor, living_room_switch)
bedroom_zone = Bedroom.new(bedroom_sensor, bedroom_switch)

zones = [living_room_zone, bedroom_zone]

puts "Setting up databin"
databin_id = "djEzlb5f"
data_bin = WolframDatabin::Base.new
data_bin.set_shortid(databin_id)

puts "Setting up screen"
screen = Adafruit::LCD::Char16x2.new

puts "Starting loop"
puts "*********************************"

Thermostat.new(zones, screen, data_bin).run
