$LOAD_PATH.unshift("/home/pi/wemote-0.2.2/lib")
require "wemote"

$LOAD_PATH.unshift("/home/pi/raspi-adafruit-ruby/lib/lcd")
require "char16x2.rb"

require "csv"
require "wolfram_databin"

require "./lib/temp_sensor.rb"
require "./lib/zone.rb"
require "./lib/bedroom.rb"
require "./lib/living_room.rb"
require "./lib/ip_finder.rb"
require "./lib/tp_link.rb"

class Thermostat
  THRESHOLD = 1

  attr_accessor :zones, :screen, :data_bin

  def initialize(zones, screen, data_bin)
    @zones = zones
    @screen = screen
    @data_bin = data_bin
  end

  def run
    while true
      zones_info = {}

      zones.each do |zone|
        zone_temp = zone.temp
        human_temp = zone_temp.round(2)
        zone_device = zone.switch
        puts "#{zone.name} Current: #{human_temp}º"

        if zone.paused?
          puts "#{zone.name} paused"
          zones_info[zone.name] = { current: human_temp, msg: "PAS" }
          next
        end

        unless zone.within_schedule?
          puts "#{zone.name} not scheduled for #{Time.now.getlocal('-04:00').strftime("%R %p on %A")}"
          zones_info[zone.name] = { current: human_temp, msg: "OFF" }
          next
        end

        puts "#{zone.name} Target: #{zone.target_temp.round(0)}º"

        if zone_temp > (zone.target_temp + threshold) && zone_device.off?
          puts "Turning #{zone.name} A/C on"
          zone_device.on!
        elsif zone_temp < (zone.target_temp - threshold) && zone_device.on?
          puts "Turning #{zone.name} A/C off"
          zone_device.off!
        end

        zones_info[zone.name] = { target: zone.target_temp.round(0), current: human_temp }

        query = { zone: zone.name, time: Time.now.getlocal('-04:00'), temperature: zone_temp }
        data_bin.post_data(query)

        CSV.open("./tmp_log.csv", "ab") { |csv| csv << [Time.now.to_s, human_temp, zone.name] }
        puts "*********************************"
      end

      message = zones_info.map do |zone_name, zone_info|
        if zone_info[:msg]
          "#{zone_name.gsub(/[^A-Z]/, '')}: #{zone_info[:current]}#{223.chr} #{4.chr} #{zone_info[:msg]}"
        else
          "#{zone_name.gsub(/[^A-Z]/, '')}: #{zone_info[:current]}#{223.chr} #{5.chr} #{zone_info[:target]}#{223.chr}"
        end
      end.join("\n")

      #begin
      screen.clear
      screen.message(message)

      100.times do
        buttons = screen.buttons
        case
        when (buttons >> Adafruit::LCD::Char16x2::SELECT) & 1 > 0
          zones.each { |zone| zone.reset_override! }
          screen.clear
          screen.message("#{3.chr} #{Time.now.getlocal('-04:00').strftime("%b%e %I:%M %p")}\nOverride Reset")
          sleep 1
          break
        when (buttons >> Adafruit::LCD::Char16x2::LEFT) & 1 > 0
          zone = living_room_zone
          if zone.pause
            zone.unpause!
            screen.clear
            screen.message("#{zone.name}\nUnpaused")
          else
            zone.pause!
            screen.clear
            screen.message("#{zone.name}\nPaused")
          end
          sleep 1
          break
        when (buttons >> Adafruit::LCD::Char16x2::RIGHT) & 1 > 0
          zone = bedroom_zone
          if zone.pause
            zone.unpause!
            screen.clear
            screen.message("#{zone.name}\nUnpaused")
          else
            zone.pause!
            screen.clear
            screen.message("#{zone.name}\nPaused")
          end

          sleep 1
          break
        when (buttons >> Adafruit::LCD::Char16x2::UP) & 1 > 0
          override_msg = zones.map do |zone|
            zone.increase_override!
            "#{zone.name.gsub(/[^A-Z]/, '')}: #{zone.target_temp}#{223.chr} UP"
          end.join("\n")

          screen.clear
          screen.message(override_msg)
          sleep 1
          break
        when (buttons >> Adafruit::LCD::Char16x2::DOWN) & 1 > 0
          override_msg = zones.map do |zone|
            zone.decrease_override!
            "#{zone.name.gsub(/[^A-Z]/, '')}: #{zone.target_temp}#{223.chr} DOWN"
          end.join("\n")

          screen.clear
          screen.message(override_msg)
          sleep 1
          break
        end
        sleep 0.1
      end
      #rescue => e
      #puts "***** Problem printing to screen at #{(Time.now - 4*60*60).strftime("%R %p")}: #{e.class}"
      #sleep 2
      #end


      #sleep 10
    end
  end

end
