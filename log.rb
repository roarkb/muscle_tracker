#!/usr/bin/env ruby

module Log
  @file_name = LOG_FILE_NAME

  def self.entry(dialog)
    f = File.open(@file_name + ".log",  "a")
    f.write(Time.now.strftime("%Y-%m-%d %H:%M:%S - ") + dialog + "\n")
    f.close
  end
end
