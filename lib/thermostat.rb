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
require "./lib/printer.rb"

class Thermostat
  THRESHOLD = 1

  attr_accessor :zones, :screen, :zones_info

  def initialize(zones)
    @zones = zones
    @zones_info = {}
  end

  def run
    while true
      zones.each do |zone|
        zone_temp = zone.temp
        human_temp = zone_temp.round(2)
        zone_device = zone.switch
        #puts "#{zone.name} Current: #{human_temp}º"

        unless zone.eligible_to_run?
          reason = zone.ineligible_reason

          if reason == :paused
            msg = "Pause"
          elsif reason == :off_schedule
            msg = "Off"
          end
        else
          if zone_temp > (zone.target_temp + THRESHOLD) && zone_device.off?
            msg = "AC on!"
            zone_device.on!
          elsif zone_temp < (zone.target_temp - THRESHOLD) && zone_device.on?
            msg = "AC off!"
            zone_device.off!
          end
        end
        zones_info[zone.name] = {
          target: zone.target_temp.round(0),
          current: human_temp,
          msg: msg
        }

        stamp = Time.now.getlocal('-04:00').strftime("%r")

        puts "#{stamp}: #{zone.name}: #{human_temp}º #{msg}"
      end


      #15.times { puts "" }
      #screen_text

      GC.start
      sleep 10
    end
  end

  private

  def screen_text
    puts Time.now.to_s
    format = "%-6s|%8s|%8s|%-7s\n"
    printf(format, "Room", "Current", "Target", "Msg")
    zones_info.each do |zone_name, zone_info|
      printf(format, zone_name.gsub(" Room", ""), "#{zone_info[:current]}º", "#{zone_info[:target]}º", zone_info[:msg])
    end
  end

  def zone_msg(zone_name, zone_info)
    mag_prefix = "#{zone_name} Current: #{zone_info[:current]}º"
    if zone_info[:msg]
      "#{mag_prefix}\n#{zone_name}: #{zone_info[:msg]}"
    else
      "#{mag_prefix}\n#{zone_name} Target: #{zone_info[:target]}º"
    end
  end

  def listen_to_buttons
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
        toggle_zone_state(zones[0])
        sleep 1

        break
      when (buttons >> Adafruit::LCD::Char16x2::RIGHT) & 1 > 0
        toggle_zone_state(zones[1])
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
  end

  def toggle_zone_state(zone)
    if zone.within_schedule?
      toggle_zone_pause(zone)
    else
      toggle_zone_schedule_override(zone)
    end
  end

  def toggle_zone_schedule_override(zone)
    if zone.override_schedule?
      zone.return_to_schedule!
      screen.clear
      screen.message("#{zone.name}\non schedule")
    else
      zone.run_off_schedule!
      screen.clear
      screen.message("#{zone.name}\noff schedule")
    end
  end

  def toggle_zone_pause(zone)
    if zone.pause
      zone.unpause!
      screen.clear
      screen.message("#{zone.name}\nunpaused")
    else
      zone.pause!
      screen.clear
      screen.message("#{zone.name}\npaused")
    end
  end
end
