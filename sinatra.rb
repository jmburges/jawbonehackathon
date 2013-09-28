require 'sinatra'

get '/locations' do
  File.read("locations.json")
end

get '/friends' do
  File.read("friends.json")
end
