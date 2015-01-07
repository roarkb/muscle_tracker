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

get '/' do
  redirect to('/muscle_tracker')
end

get "/muscle_tracker" do
  DB.append_latest_dates
 
  events = []
  DB.select_all.sort.reverse.each do |e|
    events.push([ e[0], e[1].join(", ") ])
  end
  
  haml :main, :format => :xhtml, :locals => { :events => events }
end

post '/muscle_tracker' do
  h = params[:cb]
  
  if h.length == 1
    a = h.to_a.flatten
    
    if a[1] == "clear row"
      DB.update_value_array(a[0], [])
    end
  
  elsif h.length > 1
    a = h.keys
    DB.update_value_array(a.pop, a)
  end
  
  redirect to('/muscle_tracker')
end
