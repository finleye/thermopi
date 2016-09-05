class LivingRoom < Zone
  def name
    "Living Room"
  end

  #def within_schedule?
    #true
  #end

  def within_schedule?
    time = Time.now.getlocal('-04:00')

    # Monday through Friday, morning and evening
    if (1..5).include? time.wday
      true if (6..9).include?(time.hour) || (18..22).include?(time.hour)
    else
      # Saturday and Sunday during the day
      true if (6..23).include?(time.hour)
    end
  end

  def target_temp_for_time
    76
  end
end
