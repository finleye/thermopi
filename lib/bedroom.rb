class Bedroom < Zone
  def name
    "Bed Room"
  end

  def within_schedule?
    true
  end

  def target_temp_for_time
    time = Time.now - 4*60*60
    if (0..9).include?(time.hour) || (18..23).include?(time.hour)
      75
    else
      77
    end
  end
end
