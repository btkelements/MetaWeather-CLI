require 'readline'
load 'getMetaWeather.rb'

def prompt()
  puts
  buf = nil
  while not buf
    buf = Readline.readline("> ", true)
  end
  buf
end

def is_number?(string) 
  true if Float(string) rescue false
end

def number_input()
  num = prompt() 
  while not is_number?(num)
    print "Please enter a number."
    num = prompt()
  end
  return num.to_i 
end

def key_input(choicearr) 
  key = prompt().upcase  
  while not choicearr.member?(key)
    print "Choices are: #{choicearr}"
    key = prompt().upcase
  end
  return key 
end

def test_cli()
  puts ["MetaWeather CLI", "*" * 15, ""]
  print "Search location by (N)ame or (Z)ipcode?"
  choice = key_input(["Z", "N"])
  case choice 
    when "Z" then begin 
      print "Enter zipcode number"
      this_zipcode = get_zipcode(number_input())
      print "Select country"
      this_location = list_locations(search_latlong(*(this_zipcode[number_input()])))  
      print "Select nearest location"
      this_query = Query.new(get_record(this_location[number_input()]))
      end
    when "N" then begin
      print "Enter a city or region name (or part of it)"
      this_region = list_locations(search_location_name(prompt()))
      print "Select location"
      this_query = Query.new(get_record(this_region[number_input()]))
      end
  end
  output = this_query.to_a
  print "Would you like the 6-day (F)orecast or (T)oday's weather?"
  choice = key_input(["F", "T"])
  case choice
    when "F" then output = output + this_query.this_location_forecast.collect(&:to_a)
    when "T" then output = output + this_query.this_location_today.collect(&:to_a)
    end
  print output
  puts
end
  

if __FILE__ == $0 then  
  test_cli() 
end




