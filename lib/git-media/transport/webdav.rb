require 'git-media/transport'

# move large media to local bin

# git-media.transport wedav

# git-media. webdav stuff

module GitMedia
  module Transport
    class Webdav < Base

      def initialize(url,username,password)
        @url = url
	@username = username
	@password = password
      end

      def exist?(file)
	@webdav.exists?(file)
      end

      def read?
        @webdav.exists?(file)
      end

      def get_file(sha, to_file)
	dest_file = File.new(to_file, File::CREAT|File::RDWR)
	if sha.exist?
	  @webdav.get(sha) do |stream|
	    dest_file.write(stream)
	  end
	  dest_file.close
          return true
        end
        return false
      end

      def write?
        @webdav.exists?(file)
      end

      def put_file(sha, from_file)
        if File.exists?(from_file)
          File.open(from_file, r) do |stream|
	    @webdav.put(sha, stream, File.size(from_file))
          return true
        end
        return false
      end
      
      def get_unpushed(files)
        files.select do |f|
          !File.exist?(f)
        end
      end
      
    end
  end
end
