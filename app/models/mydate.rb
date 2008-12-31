class MyDate
  Month = { 1 =>  {:name => "january",   :days => 31,},
            2 =>  {:name => "february",  :days => 28,},
            3 =>  {:name => "march",     :days => 31,},
            4 =>  {:name => "april",     :days => 30,},
            5 =>  {:name => "may",       :days => 31,},
            6 =>  {:name => "june",      :days => 30,},
            7 =>  {:name => "july",      :days => 31,},
            8 =>  {:name => "august",    :days => 31,},
            9 =>  {:name => "september", :days => 30,},
            10 => {:name => "october",   :days => 31,},
            11 => {:name => "november",  :days => 30,},
            12 => {:name => "december",  :days => 31,} }
  
  MAX_DATE = 1999999999
  
  # Returns <code>Time</code> class which will be
  # craeted from given attributes. Date_select is
  # a template for generating html select tags
  # This method fetchces parameters for day, moth and year 
  # and returns an instance od <code>Time</code> class
  def self.date_from_date_select(date,name) #variable date can have multiple date_selects => variable name
    day = date["#{name}(3i)"].to_i
    month = date["#{name}(2i)"].to_i
    year = date["#{name}(1i)"].to_i
    return Time.utc(year,month,day)
  end
  
  # Returns instances of <code>Time</code> class
  # from given parameters of html select tags.
  def self.get_dates(date, start_name, end_name)
    dates = {}
    dates[:from] = MyDate::date_from_date_select(date, start_name)
    dates[:to]   = MyDate::date_from_date_select(date, end_name)
    return dates
  end
  
  def self.seconds_to_days(seconds)
    return seconds/(24*3600)
  end
  
  def self.count_days_from_now_to(date_int)
    seconds = self.today - self.deadline
    return MyDate::seconds_to_days(seconds)
  end
  
  def self.leap_year(year)
    return (year % 100 % 4) == 0
  end   
       
  def self.days_in_month(month)
    if Month[month][:name] == :feb && leap_year(Time.now.year)
      return 29
    else
      return Month[month][:days]  
    end
  end
  
  def self.month_name(int)
    if int < 13 && int > 0
      return Month[int][:name]
    end
  end
  
  # MEthod checks if specified date exists
  def self.verify(year, month, day)
    if year && month && day
      if (day <= Month[month][:days])||(month == 2 && day == 29 && leap_year(year))
        return true
      end
    end
    return false
  end
  
  # Method return date for actual day
  def self.now
    return [Time.now.day, Time.now.mon, Time.now.year].join(".") 
  end
  
  # Return instance of <code>Time</code> class which
  # represents time of actual day
  def self.today(return_int = true)
    if return_int
      return Time.utc(Time.now.year, Time.now.mon, Time.now.day).to_i
    else
      return Time.utc(Time.now.year, Time.now.mon, Time.now.day)
    end
  end
  
  # REturns time from given seconds
  def self.time(seconds = 0)
    if seconds != 0
      time = Time.at(seconds)
    else
      time = Time.now
    end
    
    if time.min / 10 == 0
      min = "0" + time.min.to_s
    else
      min = time.min
    end
    return [time.hour, min].join(":")
  end
  
  # From given seconds this method returns
  # an instance of <code>Time</code> class.
  def self.date_at(seconds, include_time = false)
    return if (!seconds || seconds == 0 || !seconds.is_a?(Integer))
    temp = Time.at(seconds)
    if temp.day < 10
      day = "0#{temp.day}"
    else
      day = temp.day
    end
    if temp.month < 10
      month = "0#{temp.month}"
    else
      month = temp.month
    end
    date = [day, month, temp.year]
    if include_time
      return "#{date.join(".")} #{time(seconds)}"
    else
      return date.join(".")
    end
  end
  
  # Returns number of the last day in specified month.
  def self.last_day_in_month(month_number = nil, year = nil)
    if ((month_number) && (year))
      last_day = Time.utc(year, month_number, self::Month[month_number.to_i][:days])
    elsif month_number
      last_day = Time.utc(Time.now.year, month_number, self::Month[month_number.to_i][:days])
    elsif year
      last_day = Time.utc(year, Time.now.month, self::Month[month_number.to_i][:days])
    else
      last_day = Time.utc(Time.now.year, Time.now.month, MyDate::Month[month_number.to_i][:days])
    end
    
    return last_day
  end
  
end











