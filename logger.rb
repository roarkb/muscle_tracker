#!/usr/bin/env ruby

class Logger
  def initialize(file_name)
    @file_name = file_name
  end

  def entry(dialog)
    f = File.open(@file_name + ".log",  "a")
    f.write(Time.now.strftime("%Y-%m-%d %H:%M:%S - ") + dialog + "\n")
    f.close
  end
end
