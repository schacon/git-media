require 'git-media/transport'
require 'right_aws'

# git-media.transport s3
# git-media.s3bucket
# git-media.s3key
# git-media.s3secret

module GitMedia
  module Transport
    class S3 < Base

      def initialize(bucket, access_key_id = nil, secret_access_key = nil)
        @s3 = RightAws::S3Interface.new(access_key_id, secret_access_key,
              {:multi_thread => true, :logger => Logger.new(File.expand_path('~/.git-media.s3.log'))})
        @bucket = bucket
        @buckets = @s3.list_all_my_buckets.map { |a| a[:name] }
        if !@buckets.include?(bucket)
          puts "Creating New Bucket"
          if @s3.create_bucket(bucket)
            @buckets << bucket
          end
        end
      end

      def read?
        @buckets.size > 0
      end

      def get_file(sha, to_file)
        to = File.new(to_file, File::CREAT|File::RDWR)
        @s3.get(@bucket, sha) do |chunk|
          to.write(chunk)
        end
        to.close
      end

      def write?
        @buckets.size > 0
      end

      def put_file(sha, from_file)
        @s3.put(@bucket, sha,  File.open(from_file))
      end

      def get_unpushed(files)
        keys = @s3.list_bucket(@bucket).map { |f| f[:key] }
        files.select do |f|
          !keys.include?(f)
        end
      end

    end
  end
end
