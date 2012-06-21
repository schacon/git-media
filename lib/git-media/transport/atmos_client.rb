require 'git-media/transport'
require 'atmos'

# git-media.transport atmos
# git-media.endpoint
# git-media.uid
# git-media.secret
# git-media.tag (optional)

module GitMedia
  module Transport
    class AtmosClient < Base

      def initialize(endpoint, uid, secret, tag)
        atmos_options = {
          :url => endpoint,
          :uid => uid,
          :secret => secret
        }
        @tag = tag
        @atmos_client = Atmos::Store.new(atmos_options)
      end

      def read?
        reachable?
      end

      def get_file(sha, to_file)
        dst_file = File.new(to_file, File::CREAT|File::RDWR)
        @atmos_client.get(:namespace => sha).data_as_stream do |chunck|
          dst_file.write(chunck)
        end
      end

      def write
        reachable?
      end

      def put_file(sha, from_file)
        src_file = File.open(from_file)
        obj_conf = {:data => src_file, :length => File.size(from_file), :namespace => sha}
        obj_conf[:listable_metadata] = {@tag => true} if @tag
        @atmos_client.create(obj_conf)
      end

      def get_unpushed(files)
        unpushed = []
        files.each do |file|
          begin
            @atmos_client.get(:namespace => file)
          rescue Atmos::Exceptions::AtmosException
            unpushed << file
          end
        end
        unpushed
      end

      private
      # dummy function to test connectivity to atmos
      def reachable?
        @atmos_client.server_version
        true
      rescue
        false
      end

    end
  end
end


