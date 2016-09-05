class Bedroom < Zone
  def name
    "Bed Room"
  end

  def within_schedule?
    # Always on
    true
  end

  def target_temp_for_time
    time = Time.now.getlocal('-04:00')
    # Warmer Monday through Friday between 8AM and 5PM
    if (1..5).include? time.wday && (8..17).include?(time.hour)
      79
    else
      76
    end
  end
end
