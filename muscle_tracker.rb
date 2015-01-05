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
DATABASE_NAME = "muscle"

def pretty_date(date) # => thu jan 01 2015
  date.strftime("%a %b %d %y")
end

# this may not be needed
def date_to_datestamp(date)
  d = date.split("-")
  Date.new(d[0].to_i, d[1].to_i, d[2].to_i)
end

before do
  db = Database.new
  db.append_latest_dates
end

get '/' do
 redirect to('/dashboard')
end

get '/dashboard' do
  haml :dashboard, :format => :xhtml
end

get '/calendar' do
  haml :calendar, :format => :xhtml
end
