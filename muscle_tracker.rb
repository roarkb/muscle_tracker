#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml/dbm'
require 'date'
require 'fileutils'

require './database'

EXERCISES = %w[ chest back abs shoulders deltoids biceps triceps legs cardio ]
START_DATE = Date.new(2014, 12, 12)
END_DATE = Date.today 
TITLE = "Muscle Tracker"
DB_NAME = "muscle"
DB_BACKUPS_AMOUNT = 10
DB_BACKUPS_DIR = "backups"
LOG_FILE_NAME = "app"

def pretty_date(date) # => Thu, Jan 01 2015
  date.strftime("%a, %b %d %Y")
end

def date_to_datestamp(date)
  d = date.split("-")
  Date.new(d[0].to_i, d[1].to_i, d[2].to_i)
end

def backup_database
  FileUtils.mkdir_p(DB_BACKUPS_DIR)
  FileUtils.cp("#{DB_NAME}.db", "#{DB_BACKUPS_DIR}/#{DB_NAME}.db.bak_#{Date.today}")
  
  all_files = Dir["#{DB_BACKUPS_DIR}/*"]
  
  if all_files.length > DB_BACKUPS_AMOUNT
    file_dates = []
    
    all_files.each do |file|
      file_dates.push(file.gsub("#{DB_BACKUPS_DIR}/#{DB_NAME}.db.bak_", ""))
    end
   
    file_dates.sort.reverse.pop(all_files.length - DB_BACKUPS_AMOUNT).each do |date|
      FileUtils.remove("#{DB_BACKUPS_DIR}/#{DB_NAME}.db.bak_#{date}")
    end
  end
end

db = Database.new(DB_NAME)

get '/' do
  redirect to('/muscle_tracker')
end

get "/muscle_tracker" do
  db.append_latest_dates
  all = db.select_all.sort.reverse
 
  cal_data = []
  all.each do |e|
    cal_data.push([ e[0], e[1].join(", ") ])
  end

  dash_data = {}
  EXERCISES.each do |exercise|
    all.each do |event|
      date = event[0]
      items = event[1]

      if items.include?(exercise)
        dash_data[exercise] = [ date, (Date.today - date_to_datestamp(date)).to_i ]
        break
      end
    end
  end

  haml :main, :format => :xhtml, :locals => { :cal_data => cal_data, :dash_data => dash_data }
end

post "/update_row" do
  h = params[:cb]
  
  if h.length == 1
    a = h.to_a.flatten
    
    if a[1] == "clear row"
      db.update_value_array(a[0], [])
    end
  
  elsif h.length > 1
    a = h.keys
    db.update_value_array(a.pop, a)
  end
  
  redirect to('/muscle_tracker')
end

post "/backup" do
  backup_database
  redirect to('/muscle_tracker')
end
