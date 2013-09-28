require 'bundler'
Bundler.require

Dir.glob('./lib/*.rb') do |model|
  require model
end

class JawboneApp < Sinatra::Base
  
  configure do
    set :root, File.dirname(__FILE__)
    set :public_folder, 'public'
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

  helpers do
    def adv_partial(template,locals=nil)
      if template.is_a?(String) || template.is_a?(Symbol)
        template = :"_#{template}"
      else
        locals=template
        template = template.is_a?(Array) ? :"_#{template.first.class.to_s.downcase}" : :"_#{template.class.to_s.downcase}"
      end
      if locals.is_a?(Hash)
        haml template, {}, locals      
      elsif locals
        locals=[locals] unless locals.respond_to?(:inject)
        locals.inject([]) do |output,element|
          output << haml(template,{},{template.to_s.delete("_").to_sym => element})
        end.join("\n")
      else 
        haml template
      end
    end
  end
end
