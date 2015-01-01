#!/usr/bin/env ruby

# start with "rackup"
# muscle tracker live at:
# http://localhost:9292/dashboard
#
# good Sinatra + Haml tutorial:
# http://code.tutsplus.com/tutorials/an-introduction-to-haml-and-sinatra--net-14858
# 
# getting Sinatra working with Rack:
# https://www.digitalocean.com/community/tutorials/how-to-install-and-get-started-with-sinatra-on-your-system-or-vps
#
# ruby + android:
# https://github.com/ruboto/ruboto/blob/master/README.md
# 
# using a yaml database
# http://www.techrepublic.com/blog/software-engineer/simple-data-storage-with-ruby/

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
