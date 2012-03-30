require 'xmlrpc/client'
require 'yaml'

module Joomeo
  class Client
  
    API_URL = 'http://api.joomeo.com'
  
    attr_reader :apikey, :sessionid
    
    def _dump level
      [@apikey, @login, @password, @spacename, @sessionid, @session_time].to_yaml
    end

    def self._load args 
      apikey, 
        login, 
        password, 
        spacename, 
        sessionid,
        session_time = YAML.load(args)
  
      new(
        :apikey     => apikey, 
        :login      => login, 
        :password   => password, 
        :spacename  => spacename,
        :sessionid  => sessionid,
        :session_time => session_time
      )
    end
  
    def initialize options
      @apikey    = options[:apikey]
      @login     = options[:login]
      @password  = options[:password]
      @spacename = options[:spacename]
    
      if(options[:sessionid] && options[:session_time])
        @sessionid    = options[:sessionid]
        @session_time = options[:session_time]
      end
    
      ensure_valid_session!
    end
    
    def albums
      @albums ||= call('joomeo.user.getAlbumList').map {|a| Album.new(self, a)}
    end
    
    def album label
      albums.find {|a| a.label == label}
    end
 
  
    def ensure_valid_session!
      if @session_time && @sessionid
        login! if Time.now - @session_time >= 3600
      else
        login!
      end
    end

    def call method, args = {}
      with_connection do |connection|
        success, result = connection.call2(method, {:apikey => @apikey, :sessionid => @sessionid}.merge(args))
    
        if success
          result
        else
          raise result
        end
      end
    end
  
    private
  
    def with_connection

      @connection ||= XMLRPC::Client.new2("#{API_URL}/xmlrpc.php")
    
      yield @connection
      
    rescue XMLRPC::FaultException => e
    
      retried ||= 0

      unless retried >= 3
        retried += 1
        login!
        retry
      end
      raise e
    
    rescue EOFError => e
    
      retried ||= 0
    
      unless retried >= 3
        retried += 1
        retry
      end
      raise e
    end
  
    def login!
      with_connection do |connection|
        success, result = connection.call2('joomeo.session.init',
          :apikey     => @apikey,
          :spacename  => @spacename,
          :login      => @login,
          :password   => @password
        )
      
        raise 'Can\'t login with the given credentials' unless success
        @session_time = Time.now
        @albums = nil
        @sessionid = result['sessionid']
      end
    end
  end
end