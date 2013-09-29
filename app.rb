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
    provider :foursquare,
      ENV['FOURSQUARE_CONSUMER_KEY'],
      ENV['FOURSQUARE_CONSUMER_SECRET']
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

    haml :index
  end

  get '/checkins' do
    client = Jawbone::Client.new session[:jawbone_token]
    foursquare_client = Foursquare2::Client.new(:oauth_token => session[:foursquare_token])
    start_date = DateTime.now - 300
    checkins=[]
    foursquare_thread = Thread.new{
      checkins = foursquare_client.user_checkins({
      :afterTimestamp => start_date.strftime("%s"),
      :limit => 250
    })["items"]
    items = checkins.size

    while items == 250
      result=foursquare_client.user_checkins({
        :afterTimestamp => start_date.strftime("%s"),
        :limit => 250,
        :offset => checkins.size
      })["items"]
      items = result.size
      checkins+=result
    end
    }
    sleeps=[]
    jawbone_thread = Thread.new{
      temp =client.sleeps({
      :start_time => start_date.strftime("%s"),
      :end_time => DateTime.now.strftime("%s")
    })
    sleeps = temp["data"]["items"]
    while !temp["data"]["links"].nil? and !temp["data"]["links"]["next"].nil?
      temp= client.sleeps_next(temp["data"]["links"]["next"])
      sleeps += temp["data"]["items"]
    end
    }
    jawbone_thread.join
    foursquare_thread.join
    json_out=[]
    checkins.each do |checkin|
      if checkin["venue"].nil?
        break;
      end
      createdat = DateTime.strptime(checkin["createdAt"].to_s,"%s")
      sleep_index=0
      sleep_totals = []
      sleeps[sleep_index..-1].each_index do |i|
        sleep_start = DateTime.strptime(sleeps[i]["time_created"].to_s, "%s")
        sleep_end = DateTime.strptime(sleeps[i]["time_completed"].to_s, "%s")
        if (sleep_start-createdat<1 and sleep_start-createdat>0)

          if sleep_start.day == createdat.day
            sleep_totals << sleeps[i]["details"]["duration"]
          else
            if sleep_end.hour <=12 or sleeps[i]["details"]["duration"]>=3600
              sleep_totals << sleeps[i]["details"]["duration"]
            end
          end
          sleep_index = i;
        end
      end
      checkin["sleep"]=sleep_totals.empty? ? Random.new.rand(7200..36000) : sleep_totals.inject(:+)
      checkin["quality"] = Random.new.rand(10..100)
      checkin["mood"] = "Awesome"
      json_out << checkin
    end

    content_type :json
    json_out.to_json
  end

  get '/locations' do
    # File.read("locations.json")
    client = Jawbone::Client.new session[:jawbone_token]
    foursquare_client = Foursquare2::Client.new(:oauth_token => session[:foursquare_token])
    start_date = DateTime.now - 300
    checkins=[]
    foursquare_thread = Thread.new{
      checkins = foursquare_client.user_checkins({
      :afterTimestamp => start_date.strftime("%s"),
      :limit => 250
    })["items"]
    items = checkins.size

    while items == 250
      result=foursquare_client.user_checkins({
        :afterTimestamp => start_date.strftime("%s"),
        :limit => 250,
        :offset => checkins.size
      })["items"]
      items = result.size
      checkins+=result
    end
    }
    sleeps=[]
    jawbone_thread = Thread.new{
      temp =client.sleeps({
      :start_time => start_date.strftime("%s"),
      :end_time => DateTime.now.strftime("%s")
    })
    sleeps = temp["data"]["items"]
    while !temp["data"]["links"].nil? and !temp["data"]["links"]["next"].nil?
      temp= client.sleeps_next(temp["data"]["links"]["next"])
      sleeps += temp["data"]["items"]
    end
    }
    jawbone_thread.join
    foursquare_thread.join
    location_sleeps ={}
    unique_locations = {}
    location_counter = {}
    current_date = DateTime.strptime(checkins[0]["createdAt"].to_s,"%s")
    locations = []
    checkins.each do |checkin|
      if checkin["venue"].nil?
        break;
      end
      if location_counter[checkin["venue"]["id"]].nil?
        location_counter[checkin["venue"]["id"]]=1
        unique_locations[checkin["venue"]["id"]]=checkin["venue"]
      else
        location_counter[checkin["venue"]["id"]]+=1
      end
      createdat = DateTime.strptime(checkin["createdAt"].to_s,"%s")
      if current_date.day != createdat.day 
        current_date = createdat
        locations.clear
      end
      sleep_index=0
      sleeps[sleep_index..-1].each_index do |i|
        sleep_start = DateTime.strptime(sleeps[i]["time_created"].to_s, "%s")
        sleep_end = DateTime.strptime(sleeps[i]["time_completed"].to_s, "%s")
        if (sleep_start-createdat<1 and sleep_start-createdat>0)

          if sleep_start.day == createdat.day

            if !locations.include? checkin["venue"]["id"]

              if location_sleeps[checkin["venue"]["id"]].nil?
                location_sleeps[checkin["venue"]["id"]] = [sleeps[i]["details"]["duration"]]
              else
                location_sleeps[checkin["venue"]["id"]] << sleeps[i]["details"]["duration"]
              end
                locations << checkin["venue"]["id"]
            end
          else
            if sleep_end.hour <=12 or sleeps[i]["details"]["duration"]>=3600

              if !locations.include? checkin["venue"]["id"]

              if location_sleeps[checkin["venue"]["id"]].nil?
                location_sleeps[checkin["venue"]["id"]] = [sleeps[i]["details"]["duration"]]
              else
                location_sleeps[checkin["venue"]["id"]] << sleeps[i]["details"]["duration"]
              end
                locations << checkin["venue"]["id"]
              end
            end
          end
          sleep_index = i;
        end
      end
    end

    json_out={}
    location_sleeps.each_pair do |loc_id, loc_sleeps|
      item = {
        "sleep" =>loc_sleeps.inject(:+).to_f/loc_sleeps.length,
        "quality" => Random.new.rand(10..100),
        "mood" => "Awesome",
        "checkins" => location_counter[loc_id],
        "venue"=> unique_locations[loc_id]
      }
      json_out[loc_id]=item
    end


    content_type :json
    json_out.to_json
  end

  get '/friends' do

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

  get '/auth/foursquare/callback' do
    auth = request.env['omniauth.auth']
    session[:foursquare_token] = auth["credentials"]["token"]
    session[:foursquare_id]=auth["uid"]
  end

  helpers do
    def partial(template, locals=nil)
      locals = locals.is_a?(Hash) ? locals : {template.to_sym => locals}
      template = :"_#{template}"
      haml template, locals        
    end
  end

end
