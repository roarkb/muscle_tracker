#!/usr/bin/env ruby

require './log'

class Database
  def initialize(database_name)
    @database_name = database_name
  end

  extend Log

  private
  # wrapper method for all db opperations
  def query
    db = YAML::DBM.open(@database_name)
    yield(db)
    db.close
  end
  
  # log message wrapper
  def log(method, message)
    Log.entry("#{self.class}:#{method} - #{message}")
  end

  public
  # select all from db, returns hash
  def select_all
    query { |db| return db.to_hash }
  end

  def select_day(date) # 2015-03-10
    query { |db| return db[date] }
  end

  def append_latest_dates
    query do |db|
      # generate list of all current dates
      current_dates = ((START_DATE - 1)..END_DATE).inject([]) { |a,day| a << db_date(day) }

      # get the dates that have not yet been added to db
      new_list = current_dates - db.keys
      
      # append new dates to db if any
      if new_list.length > 0
        new_list.each { |e| db[e] = [] }
        log(__method__, new_list)
      end
    end

  end

  # update value of existing record in db
  def update_row(key, array)
    query do |db|
      if db.include?(key)
        new_array = select_day(key) + array
        db[key] = order_exercises(new_array)
        log(__method__, "#{key}:#{new_array}")
      else raise "no such record \"#{key}\" in database"
      end
    end
  end
  
  def clear_row(key)
    query do |db|
      if db.include?(key)
        db[key] = []
        log(__method__, "#{key}:#{db[key]}")
      else raise "no such record \"#{key}\" in database"
      end
    end
  end  
end
