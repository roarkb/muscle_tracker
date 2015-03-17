#!/usr/bin/env ruby

module Log
  def self.entry(dialog)
    f = File.open(LOG_FILE_NAME + ".log",  "a")
    f.write(Time.now.strftime("%Y-%m-%d %H:%M:%S - ") + dialog + "\n")
    f.close
  end
end
