# find files that are placeholders (41 char) and download them
# upload files in media buffer that are not in offsite bin
require 'git-media/status'

module GitMedia
  module Sync

    def self.run!(options={})
      @push = GitMedia.get_push_transport
      @pull = GitMedia.get_pull_transport
      
      self.expand_references

      if !options.has_key?(:download_only)
        self.upload_local_cache
      end
    end
    
    def self.expand_references
      status = GitMedia::Status.find_references
      status[:to_expand].each do |file, sha|
        cache_file = GitMedia.media_path(sha)
        if !File.exist?(cache_file)
          puts "Downloading " + sha[0,8] + " : " + file
          @pull.pull(file, sha) 
        end

        puts "Expanding  " + sha[0,8] + " : " + file
        
        if File.exist?(cache_file)
          FileUtils.cp(cache_file, file)
        else
          puts 'could not get media'
        end
      end
    end
    
    def self.upload_local_cache
      # find files in media buffer and upload them
      all_cache = Dir.chdir(GitMedia.get_media_buffer) { Dir.glob('*') }
      unpushed_files = @push.get_unpushed(all_cache)
      unpushed_files.each do |sha|
        puts 'uploading ' + sha[0, 8]
        @push.push(sha)
      end
      # TODO: if --clean, remove them
    end
    
  end
end