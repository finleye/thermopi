require "./lib/thermostat.rb"

begin
  living_room_sensor = "28-04165030faff"
  bedroom_sensor = "28-041643b2f8ff"

  #puts "Setting up screen: start"
  #screen_retry_count = 0
  #begin
    #screen = Adafruit::LCD::Char16x2.new
    #puts "Setting up screen: finished"
  #rescue => e
    #screen = nil
    #puts "Setting up screen: FAILED #{e}"
    #screen_retry_count += 1
    #sleep 2
    #retry unless screen_retry_count > 10
  #end

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

  #puts "Setting up databin"
  #databin_id = "djEzlb5f"
  #data_bin = WolframDatabin::Base.new
  #data_bin.set_shortid(databin_id)

  puts "Starting loop"

  Thermostat.new(zones).run
rescue => e
  sleep 60
  puts "Script failed: #{e}\nRetrying at #{Time.now.to_s}"
  retry
end
