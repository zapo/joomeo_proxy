require './lib/joomeo'
require 'open-uri'
require 'yaml'

class JoomeoProxy < Sinatra::Base

  root_dir = File.dirname(__FILE__)

  set :environment, :production  
  set :cache      , Redis.new(:db => 1)
  set :joomeo     , YAML.load(File.open(File.join(root_dir, 'config', 'joomeo.yml')).read)

  get '/file/:filename' do
    
    type = params[:type] || 'large'
    
    joomeo_dump = settings.cache.get('joomeo')
    joomeo      = Marshal.load(joomeo_dump) rescue nil
    joomeo      = Joomeo::Client.new(settings.joomeo) unless joomeo
    if params[:album]
      file = joomeo.album(params[:album]).files.find {|f| f.name == params[:filename]} rescue nil
    else
      joomeo.albums.each do |a| 
        file = a.files.find {|f| f.name == params[:filename]}
        break if file
      end
    end
    
    
    settings.cache.set('joomeo', Marshal.dump(joomeo))
    
    if file
      content_type file.type_mime
      cache_control :private, :max_age => 3600
      etag "#{file.id}-#{type}"
            
      file.data type
    end
  end
end