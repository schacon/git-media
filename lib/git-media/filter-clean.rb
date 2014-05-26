require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterClean

    def self.run!
      # determine and initialize our media buffer directory
      media_buffer = GitMedia.get_media_buffer

      hashfunc = Digest::SHA1.new
      start = Time.now

      #read first 41 bytes and see if this is a stub
      possible_sha = STDIN.read(64) # read no more than 64 bytes
      possible_sha_strip = possible_sha.strip
      if STDIN.eof? && possible_sha_strip.length == 40 && possible_sha_strip.match(/^[0-9a-fA-F]+$/) != nil
        # STUB
        STDOUT.print(possible_sha)
        STDOUT.binmode
        STDERR.puts("Media not downloaded yet: " + possible_sha)
        return
      end      

      # read in buffered chunks of the data
      #  calculating the SHA and copying to a tempfile
      tempfile = Tempfile.new('media')
      tempfile.binmode      
      hashfunc.update(possible_sha)
      tempfile.write(possible_sha)      
      while data = STDIN.read(4096)
        hashfunc.update(data)
        tempfile.write(data)
      end
      tempfile.close

      # calculate and print the SHA of the data
      STDOUT.print hx = hashfunc.hexdigest 
      STDOUT.binmode
      STDOUT.write("\n")

      # move the tempfile to our media buffer area
      media_file = File.join(media_buffer, hx)
      FileUtils.mv(tempfile.path, media_file)

      elapsed = Time.now - start
      STDERR.puts('Saving media : ' + hx + ' : ' + elapsed.to_s)
    end

  end
end