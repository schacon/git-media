require 'pp'

module GitMedia
  module Status

    def self.run!
      @push = GitMedia.get_push_transport
      r = self.find_references
      self.print_references(r)
      r = self.local_cache_status
      self.print_cache_status(r)
    end

    # find tree entries that are likely media references
    def self.find_references
      references = {:to_expand => [], :expanded => [], :deleted => []}
      files = `git ls-tree -l -r HEAD`.split("\n")
      files = files.map { |f| s = f.split("\t"); [s[0].split(' ').last, s[1]] }
      files = files.select { |f| f[0] == '41' } # it's the right size
      files.each do |tree_size, fname|
        if size = File.size?(fname)
          if size == tree_size.to_i
            # TODO: read in the data and verify that it's a sha + newline
            sha = File.read(fname).strip
            if sha.length == 40 && sha =~ /^[0-9a-f]+$/
              references[:to_expand] << [fname, sha]
            end
          else
            references[:expanded] << fname
          end
        else
          # file was deleted
          references[:deleted] << fname
        end
      end
      references
    end

    def self.print_references(refs)
      if refs[:to_expand].size > 0
        puts "== Unexpanded Media =="
        refs[:to_expand].each do |file, sha|
          puts "   " + sha[0, 8] + " " + file
        end
        puts
      end
      if refs[:expanded].size > 0
        puts "== Expanded Media =="
        refs[:expanded].each do |file|
          size = File.size(file)
          puts "   " + "(#{self.to_human(size)})".ljust(8) + " #{file}"
        end
        puts
      end
      if refs[:deleted].size > 0
        puts "== Deleted Media =="
        refs[:deleted].each do |file|
          puts "           " + " #{file}"
        end
        puts
      end
    end

    def self.print_cache_status(refs)
      if refs[:unpushed].size > 0
        puts "== Unpushed Media =="
        refs[:unpushed].each do |sha|
          cache_file = GitMedia.media_path(sha)
          size = File.size(cache_file)
          puts "   " + "(#{self.to_human(size)})".ljust(8) + ' ' + sha[0, 8]
        end
        puts
      end
      if refs[:pushed].size > 0
        puts "== Already Pushed Media =="
        refs[:pushed].each do |sha|
          cache_file = GitMedia.media_path(sha)
          size = File.size(cache_file)
          puts "   " + "(#{self.to_human(size)})".ljust(8) + ' ' + sha[0, 8]
        end
        puts
      end
    end

    def self.local_cache_status
      # find files in media buffer and upload them
      references = {:unpushed => [], :pushed => []}
      all_cache = Dir.chdir(GitMedia.get_media_buffer) { Dir.glob('*') }
      unpushed_files = @push.get_unpushed(all_cache) || []
      references[:unpushed] = unpushed_files
      references[:pushed] = all_cache - unpushed_files rescue []
      references
    end


    def self.to_human(size)
      if size < 1024
        return size.to_s + 'b'
      elsif size < 1048576
        return (size / 1024).to_s + 'k'
      else
        return (size / 1048576).to_s + 'm'
      end
    end

  end
end
