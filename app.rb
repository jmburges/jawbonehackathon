require 'bundler'
Bundler.require

#Dir.glob('./lib/*.rb') do |model|
#  require model
#end

class JawboneApp < Sinatra::Base
  use Rack::Session::Cookie, :secret => '33west26'
  use OmniAuth::Builder do
    provider :jawbone, 
      ENV['JAWBONE_CLIENT_ID'], 
      ENV['JAWBONE_CLIENT_SECRET'], 
      :scope => "basic_read mood_read sleep_read"
  end
  
  configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, 'public'
  end

  before do
    locations_json = File.open("locations.json").read
    @locations = MultiJson.decode(locations_json)
  end

  get '/' do
    client = Jawbone::Client.new session[:jawbone_token]
    puts "#"*15
    puts client.sleeps
    puts "#"*15
    haml :index
  end

  get '/locations' do
    @locations
  end

  get '/friends' do
    File.read("friends.json")
  end

  get '/custom.css' do
    scss :custom

  end

  get '/auth/jawbone/callback' do
    auth = request.env['omniauth.auth']
    session[:jawbone_token] = auth["credentials"]["token"]
    session[:jawbone_id]=auth["uid"]
    session[:first_name] = auth["info"]["first_name"]
    session[:last_name] = auth["info"]["last_name"]
  end

  helpers do
    def partial(template, locals=nil)
      locals = locals.is_a?(Hash) ? locals : {template.to_sym => locals}
      template = :"_#{template}"
      haml template, locals        
    end
  end

end
