require "rspec"
require_relative "../lib/zone.rb"

RSpec.describe Zone, type: :model do
  let(:time_now) { Time.new(2016, 9, 26, 12, 0) }
  let(:switch) { double(:switch) }
  let(:zone) { described_class.new("sensor_id", switch) }

  before do
    allow(Time).to receive(:now).and_return(time_now)
  end

  it "should pause and set a timer" do
    expect(switch).to receive(:off!)

    zone.pause!

    expect(zone.pause_expire).to eq(time_now + Zone::PAUSE_EXPIRE)
    expect(zone.pause).to be_truthy
  end

  it "should unpause and clear timers" do
    expect(switch).to receive(:on!)

    zone.unpause!

    expect(zone.pause_expire).to be_nil
    expect(zone.pause).to be_falsey
  end

  context "check pause state" do
    it "should clear pause if it is set and past the timer" do
      zone.pause = true
      zone.pause_expire = time_now - 10*60

      zone.paused?

      expect(zone.pause_expire).to be_nil
      expect(zone.pause).to be_falsey
    end

    it "should return the pause value if it's set and not past the timer" do
      zone.pause = true
      zone.pause_expire = time_now + 10*60

      expect(zone.paused?).to be_truthy
    end

    it "should return false if the pause value hasn't been altered" do
      expect(zone.paused?).to be_falsey
    end
  end

  context "overriding schedule" do
    class TestZone < Zone
      def within_schedule?
        time = Time.now.getlocal('-04:00')

        true if time.wday == 0
      end
    end

    let(:zone) { TestZone.new("sensor_id", switch) }
    let(:within_schedule?) { double(:within_schedule) }

    it "should recognize the zone if off schedule" do
      expect(zone.within_schedule?).to be_falsey
    end

    it "should allow the zone to run even if off schedule" do
      zone.run_off_schedule!

      expect(zone.eligible_to_run?).to be_truthy
    end

    it "should reset override if the time expires" do
      zone.override_schedule = true
      zone.override_schedule_expire = time_now - 10*60

      expect(zone.eligible_to_run?).to be_falsey
    end
  end
end
