module Joomeo

  class File
    attr_accessor :fileid, 
      :filename,
      :rotation,
      :rating,
      :size,
      :width, 
      :height, 
      :type_mime, 
      :date_shooting,
      :date_creation,
      :legend,
      :albumid
    
    alias_method :id, :fileid
    alias_method :name, :filename
    
    def created_at
      Time.at(super)
    end
    
    def shooted_at
      Time.at(super)
    end
    
    def initialize client, options
      @client = client
      
      options.each do |k,v|
        var = :"@#{k}"
        instance_variable_set(var, v)
      end
    end
    
    def album
      @client.ablums(albumid)
    end
    
    def data type = 'large'
      @client.call('joomeo.user.file.getBinary', :fileid => id, :type => type)['data']
    end
    
    def url type = 'large', rotation = 0
      "#{API_URL}/file.php?apikey=#{@client.apikey}&sessionid=#{@client.sessionid}&fileid=#{fileid}&albumid=#{albumid}&type=#{type}&rotation=#{rotation}"
    end
  end
    
end