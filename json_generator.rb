require 'json'

MOODS = %w[Hungover Awesome Tired Dragging Meh Exhausted Energized]

checkins = JSON.parse(IO.read("checkins.json"))

json_out = {}

checkins["response"]["checkins"]["items"].each do |checkin|
  item = {
      "sleep" =>Random.new.rand(7200..36000),
      "quality" => Random.new.rand(10..100),
      "mood" => MOODS.sample
  }
  if json_out[checkin["venue"]["id"]].nil?
    item["checkins"]=0
  else
    item["checkins"]=json_out[checkin["venue"]["id"]]["checkins"]+1
  end
  item["venue"]=checkin["venue"]


  json_out[checkin["venue"]["id"]] = item
end

File.open("locations.json","w") do |f|
  f.write(json_out.to_json)
end

