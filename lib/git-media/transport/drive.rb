require 'git-media/transport'
require 'google_drive'

# git-media.transport drive
# git-media.email youname@gmail.com
# git-media.asp application specific password
# git-media.collection collectionName (should be shared with all users)

module GitMedia
  module Transport
    class Drive < Base

      def initialize(email, asp, collection)
        @drive = GoogleDrive.login(email, asp)
        @collection = @drive.collection_by_title(collection)
      end

      def read?
        true
      end

      def get_file(sha, to_file)
        file = @collection.files("title" => sha, "title-exact" => true).first
        file.download_to_file(to_file)
      end

      def write?
        true
      end

      def put_file(sha, from_file)
        f = @drive.upload_from_file(from_file, sha, :convert => false)
        @collection.add(f)
      end

      def get_unpushed(files)
        keys = @collection.files.map { |f| f.title }
        files.select do |f|
          !keys.include?(f)
        end
      end

    end
  end
end
