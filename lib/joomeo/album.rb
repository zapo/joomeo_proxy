module Joomeo
  class Album
    attr_accessor :albumid,
      :label,
      :createddate,
      :public,
      :folderid
    
    alias_method :id, :albumid
    
    def initialize client, options
      
      @client = client
      
      options.each do |k,v|
        instance_variable_set(:"@#{k}", v)
      end
    end
    
    def files
      @files ||= @client.call('joomeo.user.album.getFilesList', :albumid => id).map {|f| File.new(@client, f)}
    end
  end
end
