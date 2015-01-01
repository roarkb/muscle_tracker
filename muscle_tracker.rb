#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'date'

EXERCISE = %w[
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

class MuscleTrackerApp < Sinatra::Base
  title = "Muscle Tracker"
  
  get '/' do
   redirect to('/dashboard')
  end
  
  get '/dashboard' do
    haml :dashboard, :format => :xhtml, :locals => {:title => title}
  end

  get '/calendar' do
    haml :calendar, :format => :xhtml, :locals => {:title => title}
  end
end
