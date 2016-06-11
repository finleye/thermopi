class LivingRoom < Zone
  def name
    "Living Room"
  end

  def within_schedule?
    time = Time.now - 4*60*60
    if (1..5).include? time.wday #Monday - Friday
      true if (6..9).include?(time.hour) || (18..22).include?(time.hour)
    else
      true if (6..23).include?(time.hour)
    end
  end

  def target_temp_for_time
    76
  end
end
