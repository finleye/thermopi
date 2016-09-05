class Printer
  def self.loading(text)
    process = Thread.new { yield }

    i = 0
    until(yield) do
      print text +  ("." * (i % 3)) + "  \r"
      i += 1
      $stdout.flush
      sleep(0.5)
    end
  end
end
