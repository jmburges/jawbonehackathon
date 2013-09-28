require 'json'

friends = %w[Avi Adam Jeff Rebekah Blake zZak Joe Ashley Scott Spencer Bob]
moods = %w[Hungover Awesome Tired Dragging Meh Exhausted Energized]

locations = []
locations << "The Grey Bar"
locations << "Hogpit"
locations << "Bushwick Country Club"
locations << "The Flatiron School"
locations << "Stumptown Coffee Roasters"
locations << "Ace Hotel"


def process_items items
  json_out = {}

  item.each do |item|
    json_out[friend]={
      "sleep" =>Random.new.rand(7200..36000),
      "quality" => Random.new.rand(10..100),
      "mood" => moods.sample
    }
  end

  File.open("items.json","w") do |f|
    f.write(json_out.to_json)
  end
end


  File.open("friends.json","w") do |f|
    f.write(json_out.to_json)
  end
