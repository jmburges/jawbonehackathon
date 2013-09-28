require 'bundler'
Bundler.require

Dir.glob('./lib/*.rb') do |model|
  require model
end


class App < Sinatra::Base
  
  configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, 'public'
  end

  before do
    locations_json = File.open("locations.json").read
    @locations = MultiJson.decode(locations_json)
  end

  get '/' do
    haml :index
  end

  get '/locations' do
    File.read("locations.json")
  end

  get '/friends' do
    File.read("friends.json")
  end

  get '/custom.css' do
    scss :custom
  end

  helpers do
    def partial(template, locals=nil)
      locals = locals.is_a?(Hash) ? locals : {template.to_sym => locals}
      template = :"_#{template}"
      haml template, locals        
    end
  end

end
