require 'git-media/transport'

require 'uri'
require 'net/dav'


module GitMedia
  module Transport
    class WebDav < Base
      def initialize(url, user, password, verify_server=true, binary_transfer=false)
        @uri = URI(url)
        # Faster binary transport requires curb gem
        @dav = Net::DAV.new(url, :curl => (binary_transfer))
        @dav.verify_server = verify_server
        @dav.credentials(user, password)
        print 'checking connection... '
        @has_connection = @dav.exists?('.')
        puts (if @has_connection then 'ok' else 'failed' end)
      end

      def read?
        @has_connection
      end

      def write?
        @has_connection
      end

      def get_path(path)
        @uri.merge(path).path
      end

      def exists?(file)
        @dav.exists?(get_path(file))
      end

      def get_file(sha, to_file)
        to = File.new(to_file, File::CREAT|File::RDWR)
        begin
          @dav.get(get_path(sha)) do |chunk|
            to.write(chunk)
          end
          true
        ensure
          to.close
        end
      end

      def put_file(sha, from_file)
        @dav.put(get_path(sha), File.open(from_file), File.size(from_file))
      end

      def get_unpushed(files)
        files.select do |f|
          !self.exists?(f)
        end
      end

    end
  end
end
