class Zone
  PAUSE_EXPIRE = 8*60*60
  OVERRIDE_EXPIRE = 2*60*60

  attr_accessor :sensor_id, :switch, :pause, :pause_expire, :override_temp,
    :override_temp_expire, :override_schedule, :override_schedule_expire

  def initialize(sensor_id, switch)
    @sensor_id = sensor_id
    @switch = switch
    @pause = false
    @override_schedule = false
  end

  def eligible_to_run?
    !paused? && (override_schedule? || within_schedule?)
  end

  def ineligible_reason
    if paused?
      :paused
    elsif !within_schedule?
      :off_schedule
    end
  end

  def within_schedule?
    fail "Must be defined by subclasses"
  end
  alias_method :target_temp_for_time, :within_schedule?

  def run_off_schedule!
    @override_schedule = true
    @override_schedule_expire = Time.now.getlocal('-04:00') + OVERRIDE_EXPIRE
  end

  def override_schedule?
    if override_schedule &&
        !override_schedule_expire.nil? &&
        Time.now.getlocal('-04:00') > override_schedule_expire
      return_to_schedule!
    else
      override_schedule
    end
  end

  def return_to_schedule!
    @override_schedule_expire = nil
    @override_schedule = false
  end

  def pause!
    switch.off!
    @pause_expire = Time.now.getlocal('-04:00') + PAUSE_EXPIRE
    @pause = true
  end

  def unpause!
    switch.on!
    reset_pause_values!
  end

  def reset_pause_values!
    @pause_expire = nil
    @pause = false
  end

  def paused?
    if pause && !pause_expire.nil? && Time.now.getlocal('-04:00') > pause_expire
      reset_pause_values!
    else
      pause
    end
  end

  def target_temp
    if override_temp && !override_temp_expire.nil?
      if Time.now.getlocal('-04:00') > override_temp_expire
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

    update_override_expire!
  end

  def decrease_override!
    if override_temp.nil?
      @override_temp = target_temp_for_time - 1
    else
      @override_temp -= 1
    end

    update_override_expire!
  end

  def reset_override!
    @override_temp = nil
    @override_temp_expire = nil
  end

  def update_override_expire!
    @override_temp_expire = Time.now.getlocal('-04:00') + OVERRIDE_EXPIRE
  end

  def temp
    TempSensor.new(sensor_id).temp
  end
end
