#!/usr/bin/env ruby

class Database
  def initialize(database_name)
    @database_name = database_name
  end

  private
  # wrapper method for all db opperations
  def query
    db = YAML::DBM.open(@database_name)
    yield(db)
    db.close
  end

  public
  # select all from db, returns hash
  def select_all
    query { |db| return db.to_hash }
  end

  def append_latest_dates
    query do |db|
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
  end

  # update value of existing record in db
  def update_value_array(key, array)
    query do |db|
      if db.include?(key)
        db[key] = array
      else raise "no such record \"#{key}\" in database"
      end
    end
  end  
end