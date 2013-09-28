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

json_out = {}
300.times do |i|
  date = Time.new() - (i*86400)
  sleep_today = Random.new.rand(7200..36000)
  quality = Random.new.rand(10..100)
  json_out[date]= {
    "sleep" => sleep_today,
    "sleep_quality" => quality,
    "friends" => friends.sample(Random.new.rand(0..11)),
    "moods" => moods.sample(Random.new.rand(0..7))
  }
end

File.open("temp.json","w") do |f|
  f.write(json_out.to_json)
end

