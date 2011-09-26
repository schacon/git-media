module GitMedia
  module FilterSmudge

    def self.run!
      media_buffer = GitMedia.get_media_buffer
      can_download = false # TODO: read this from config and implement
      
      # read checksum size
      sha = STDIN.readline(64).strip # read no more than 64 bytes
      if STDIN.eof? && sha.length == 40 && sha.match(/^[0-9a-fA-F]+$/) != nil
        # this is a media file
        media_file = File.join(media_buffer, sha.chomp)
        if File.exists?(media_file)
          STDERR.puts('recovering media : ' + sha)
          File.open(media_file, 'r') do |f|
            while data = f.read(4096) do
              print data
            end
          end
        else
          # TODO: download file if not in the media buffer area
          if !can_download
            STDERR.puts('media missing, saving placeholder : ' + sha)
            puts sha
          end
        end
      else
        # if it is not a 40 character long hash, just output
        STDERR.puts('Unknown git-media file format')
        print sha
        while data = STDIN.read(4096)
          print data
        end
      end
    end

  end
end