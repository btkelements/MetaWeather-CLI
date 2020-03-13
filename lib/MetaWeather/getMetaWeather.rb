require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'json'

# this app uses the MetaWeather API, following the specifications contained in its website:
# https://www.metaweather.com/api/

def query_weather(query)  
  begin                   
    JSON.parse(Nokogiri::HTML.parse(open("https://www.metaweather.com/api/location/#{query}")))
  rescue
    print($!)
    return nil
  end
end   

def list_locations(loc_arr)  
  loc_arr.each_with_index {|loc, ind| puts "#{ind} #{loc["title"]}"}  
  loc_arr.collect {|l| l["woeid"]}  
end

def search_location_name(locstring)  
  query_weather("search/?query=#{locstring}")  
end

def search_latlong(latf, longf)  
  query_weather("search/?lattlong=#{latf},#{longf}") 
end

def get_zipcode(zipcodeint)  
  zips = JSON.parse(Nokogiri::HTML.parse(open("https://geocode.xyz/#{zipcodeint}?json=1")))["alt"]["loc"].collect {|z| 
    [ z["countryname"], [z["latt"].to_f, z["longt"].to_f] ] }
  zips.each_with_index {|z, ind| puts "#{ind} #{z[0]}"} 
  zips.collect {|z| z[1]}
end

def get_datatoday(woeid)
  query_weather("#{woeid}/#{Date.today.strftime("%Y/%m/%d")}").select {|i| 
    Date.parse(i["created"]) == Date.today }
end 

def get_dataforecast(woeid) 
  query_weather("#{woeid}") 
end

def get_record(woeid)
  { :today => get_datatoday(woeid), :forecast => get_dataforecast(woeid) }
end 

class Query
  attr_reader :name, :this_location_forecast, :this_location_today

  def initialize(weather_record)
    @this_location_today = weather_record[:today].collect {|f| Location_Today.new(f) }.reverse
    @this_location_forecast = weather_record[:forecast]["consolidated_weather"].collect {|f| Location_Forecast.new(f) }
    @name = weather_record[:forecast]["title"] 
  end

  def to_s() 
    "#{self.name}"
  end
  
  def to_a()
    [ self.name ]
  end

  class Location
    attr_reader :weather_state_name, :min_temp, :the_temp, :max_temp, :wind_direction_compass,
      :wind_speed, :air_pressure, :humidity, :visibility
 
    def initialize(weather_field)
      @weather_state_name, @min_temp, @the_temp, @max_temp, @wind_direction_compass, 
        @wind_speed, @air_pressure, @humidity, @visibility = weather_field.fetch_values("weather_state_name", 
          "min_temp", "the_temp", "max_temp", "wind_direction_compass", "wind_speed", "air_pressure", "humidity",
          "visibility")
    end
    
    def to_a()
      [ self.weather_state_name, self.the_temp, self.min_temp, self.max_temp, self.wind_direction_compass, 
        self.wind_speed, self.air_pressure, self.humidity, self.visibility ]
    end
    
  end
  
  class Location_Forecast < Location
    attr_reader :date
  
    def initialize(weather_field)
      super
      @date = weather_field["applicable_date"]
    end
    
    def to_s
      "#{self.date}"
    end
    
    def to_a  
      [ self.to_s ] + super
    end
    
    
  end

  class Location_Today < Location
    attr_reader :time
  
    def initialize(weather_field)
      super 
      @time = Time.parse(weather_field["created"].gsub('Z', ''))  
    end
  
    def print_time
      @time.strftime('%I:%M %p')
    end
    
    def print_date 
      @time.strftime('%d/%-m/%y') 
    end
    
    def to_s 
      "#{self.print_date} #{self.print_time}"
    end
    
    def to_a
      [ self.to_s ] + super
    end
    
  end

end

