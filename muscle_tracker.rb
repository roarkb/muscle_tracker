#!/usr/bin/env ruby

# gems
require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml/dbm'

# bilt-in libs
require 'date'
require 'fileutils'

EXERCISES = %w[ chest triceps traps shoulders deltoids biceps back low_back legs abs cardio ]
START_DATE = Date.new(2015, 3, 11) # YYYY, M, D
END_DATE = Date.today 
TITLE = "Muscle Tracker"
DB_NAME = "muscle"
DB_BACKUPS_AMOUNT = 10
DB_BACKUPS_DIR = "backups"
LOG_FILE_NAME = "app"
HOME_DIR = "/muscle-tracker"
APP_URL = "http://localhost:4567#{HOME_DIR}"

# files
require './database'
require './log'

def pretty_date(date) # => Thu, Jan 01 2015
  date.strftime("%a, %b %d %Y")
end

def date_to_datestamp(date)
  d = date.split("-")
  Date.new(d[0].to_i, d[1].to_i, d[2].to_i)
end

# yaml/dbm cannot store timestamps so need to convert to "YYYY-MM-DD" before all db transactions
def db_date(date) # => 2015-03-10
  date.strftime("%Y-%m-%d")
end

# log message wrapper
def log(method, message)
  Log.entry("#{File.basename(__FILE__).gsub(".rb", "")}:#{method} - #{message}")
end

# order a days exercise list like EXERCISES array
def order_exercises(array)
  # cant use inject here for some reason - "undefined method `<<' for nil:NilClass"
  ordered = []
  EXERCISES.each { |e| ordered << e if array.include?(e) }
  ordered
end

# STARTUP

db = Database.new(DB_NAME)
db.append_latest_dates

# make sure hidden day before first date is populated with all exercises or app wont run
day_before = db_date(START_DATE - 1)

unless EXERCISES == db.select_day(day_before)
  db.update_row(day_before, EXERCISES)

  # reorder all exercises in calendar view on startup if order has changed
  db.select_all.each_key { |date| db.update_row(date, []) }
end

puts "\napp url: #{APP_URL}\n\n..."
log("startup", "app url: #{APP_URL}")

# APP

get '/' do
  redirect to(HOME_DIR)
end

get HOME_DIR do
  db.append_latest_dates

  all = db.select_all.sort.reverse
  cal_data = all.inject([]) { |a,e| a << [ e[0], e[1].join(", ") ] }
  
  dash_data = EXERCISES.inject({}) do |h,exercise|
    all.each do |event|
      date = event[0]
      items = event[1]

      if items.include?(exercise)
        h[exercise] = [ date, (Date.today - date_to_datestamp(date)).to_i ]
        break
      end
    end

    h
  end
  
  haml :main, :format => :xhtml, :locals => { :cal_data => cal_data, :dash_data => dash_data }
end

post "/update-row" do
  h = params[:cb]
  
  if h.length == 1
    a = h.to_a.flatten
    
    if a[1] == "clear row"
      db.clear_row(a[0])
    end
  
  elsif h.length > 1
    a = h.keys
    db.update_row(a.pop, a)
  end
  
  log(__method__, h)
  redirect to(HOME_DIR)
end

post "/backup" do
  FileUtils.mkdir_p(DB_BACKUPS_DIR)
  new_file = "#{DB_BACKUPS_DIR}/#{DB_NAME}.db.bak_#{Date.today}"
  FileUtils.cp("#{DB_NAME}.db", new_file)
  log(__method__, new_file)
  all_files = Dir["#{DB_BACKUPS_DIR}/*"]
  
  if all_files.length > DB_BACKUPS_AMOUNT
    file_dates = all_files.inject([]) do |a,file|
      a << file.gsub("#{DB_BACKUPS_DIR}/#{DB_NAME}.db.bak_", "")
    end
   
    files_to_remove = file_dates.sort.reverse.pop(all_files.length - DB_BACKUPS_AMOUNT)
    
    if files_to_remove.length > 0
      files_to_remove.each do |date|
        FileUtils.remove("#{DB_BACKUPS_DIR}/#{DB_NAME}.db.bak_#{date}")
      end
  
      log(__method__, "removed file(s) with date(s): #{files_to_remove}")
    end
  end
  
  redirect to(HOME_DIR)
end
