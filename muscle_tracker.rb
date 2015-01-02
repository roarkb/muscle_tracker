#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml/dbm'
require 'date'

EXERCISES = %w[
  chest
  back
  abs
  shoulders
  deltoids
  biceps
  triceps
  legs
  run
]

START_DATE = Date.new(2014, 12, 12)
END_DATE = Date.today 
TITLE = "Muscle Tracker"

class MuscleTrackerApp < Sinatra::Base
  def pretty_date(date) # => Thu Jan 01 2015
    date.strftime("%a %b %d %Y")
  end

  # this may not be needed
  def date_to_datestamp(date)
    d = date.split("-")
    Date.new(d[0].to_i, d[1].to_i, d[2].to_i)
  end

  # select all from db
  def db_all(db)
    all = []
    db.each { |k,v| all.push("#{k} => #{v}") }
    all.sort.each { |e| puts e }
  end

  def db_append_latest_dates(db)
    # generate list of all current dates
    # yaml/dbm cannot store timestamps so need to convert to "YYYY-MM-DD" before all db transactions
    current_dates = []
    (START_DATE..END_DATE).each { |day| current_dates.push(day.strftime("%Y-%m-%d")) }

    # get the dates that have not yet been added to db
    new_list = current_dates - db.keys
    
    # append new dates to db if any
    if new_list.length > 0
      new_list.each do |e|
        db[e] = []
      end
    end
  end

  # update value of existing record in db
  def db_update_value_array(db, key, array)
    if db.include?(key)
      db[key] = array
    else raise "no such record \"#{key}\" in database"
    end
  end
  
  before do
    db = YAML::DBM.open("muscle")
    db_append_latest_dates(db)
    db.close
  end

  get '/' do
   redirect to('/dashboard')
  end
  
  get '/dashboard' do
    haml :dashboard, :format => :xhtml #, :locals => {:title => title}
  end

  get '/calendar' do
    haml :calendar, :format => :xhtml
  end
end
