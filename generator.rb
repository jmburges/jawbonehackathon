require 'jawbone'
require 'httparty'
require 'date'

class Generator

include HTTParty

def create_sleep time_created, time_completed


 response = self.class.post "https://jawbone.com/nudge/api/users/@me/sleeps",
        { :headers => 
          { "Authorization" => "Bearer #{token}", 
            "Content-Type" => "application/x-www-form-urlencoded" },
          :body => {
         :time_created => "#{time_created}",
         :time_completed => "#{time_completed}"
          }
        }
 response.parsed_response

#    client = Jawbone::Client.new token
# puts   client.sleeps
end

end

300.times do |i|
  hours = [21,22,23,0,1,2,3]
  random_hour = hours.sample
  day = i
  if random_hour < 21
    day += 1
  end
  now = DateTime.now - (day)
  begin_date = DateTime.new(now.year,now.month,now.day, random_hour, Random.new.rand(1..59))
  end_date = begin_date + Rational(Random.new.rand(3..11),24)
  end_date = DateTime.new(end_date.year,end_date.month,end_date.day,end_date.hour,Random.new.rand(1..59))

  gen = Generator.new
puts  gen.create_sleep begin_date.strftime("%s"), end_date.strftime("%s")
end
# gen = Generator.new
# gen.create_sleep


