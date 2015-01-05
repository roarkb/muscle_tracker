#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml/dbm'
require 'date'

require './database'

EXERCISES = %w[ chest back abs shoulders deltoids biceps triceps legs cardio ]
START_DATE = Date.new(2014, 12, 12)
END_DATE = Date.today 
TITLE = "Muscle Tracker"
DB = Database.new("muscle")

def pretty_date(date) # => Thu, Jan 01 2015
  date.strftime("%a, %b %d %Y")
end

def date_to_datestamp(date)
  d = date.split("-")
  Date.new(d[0].to_i, d[1].to_i, d[2].to_i)
end

before do
  DB.append_latest_dates
  #DB.update_value_array("2014-12-31", [ "chest", "back", "abs", "shoulders", "deltoids", "biceps", "triceps", "legs", "cardio" ])
end

get '/' do
 redirect to('/dashboard')
end

get '/dashboard' do
  haml :dashboard, :format => :xhtml
end

get '/calendar' do
  
  events = []
  DB.select_all.sort.each do |e|
    events.push([ pretty_date(date_to_datestamp(e[0])), e[1].join(", ") ])
  end

  haml :calendar, :format => :xhtml, :locals => { :events => events }
end
