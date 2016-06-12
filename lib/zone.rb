class Zone
  PAUSE_EXPIRE = 8*60*60
  OVERRIDE_EXPIRE = 2*60*60

  attr_accessor :sensor_id, :switch, :pause, :pause_expire, :override_temp, :override_expire

  def initialize(sensor_id, switch)
    @sensor_id = sensor_id
    @switch = switch
    @pause = false
  end

  def pause!
    switch.off!
    @pause_expire = Time.now.getlocal('-04:00') + PAUSE_EXPIRE
    @pause = true
  end

  def unpause!
    switch.on!
    @pause_expire = nil
    @pause = false
  end

  def paused?
    if pause && !pause_expire.nil? && Time.now.getlocal('-04:00') > pause_expire
      @pause_expire = nil
      @pause = false
    else
      pause
    end
  end

  def target_temp
    if override_temp && !override_expire.nil?
      if Time.now.getlocal('-04:00') > override_expire
        reset_override!
        target_temp_for_time
      else
        override_temp
      end
    else
      target_temp_for_time
    end
  end

  def increase_override!
    if override_temp.nil?
      @override_temp = target_temp_for_time + 1
    else
      @override_temp += 1
    end
    update_override_expire
  end

  def decrease_override!
    if override_temp.nil?
      @override_temp = target_temp_for_time - 1
    else
      @override_temp -= 1
    end
    update_override_expire
  end

  def reset_override!
    @override_temp = nil
    @override_expire = nil
  end

  def update_override_expire
    @override_expire = Time.now.getlocal('-04:00') + OVERRIDE_EXPIRE
  end

  def temp
    TempSensor.new(sensor_id).temp
  end
end
