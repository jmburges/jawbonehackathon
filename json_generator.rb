require 'json'

MOODS = %w[Hungover Awesome Tired Dragging Meh Exhausted Energized]



def process_items items
  json_out = {}

  items.each do |item|
    json_out[item]={
      "sleep" =>Random.new.rand(7200..36000),
      "quality" => Random.new.rand(10..100),
      "mood" => MOODS.sample
    }
  end

  json_out
end


File.open("friends.json","w") do |f|
  json_out = process_items %w[Avi Adam Jeff Rebekah Blake zZak Joe Ashley Scott Spencer Bob]
  f.write(json_out.to_json)
end

File.open("locations.json","w") do |f|
  locations = []
  locations << "The Grey Bar"
  locations << "Hogpit"
  locations << "Bushwick Country Club"
  locations << "The Flatiron School"
  locations << "Stumptown Coffee Roasters"
  locations << "Ace Hotel"
  json_out = process_items locations
  f.write(json_out.to_json)
end
