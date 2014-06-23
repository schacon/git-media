require 'trollop'
require 'fileutils'
require 'git-media/transport/local'
require 'git-media/transport/s3'
require 'git-media/transport/scp'

module GitMedia

  def self.get_media_buffer
    @@git_dir ||= `git rev-parse --git-dir`.chomp
    media_buffer = File.join(@@git_dir, 'media/objects')
    FileUtils.mkdir_p(media_buffer) if !File.exist?(media_buffer)
    return media_buffer
  end

  def self.media_path(sha)
    buf = self.get_media_buffer
    File.join(buf, sha)    
  end
  
  # TODO: select the proper transports based on settings
  def self.get_push_transport
    self.get_transport
  end

  def self.get_transport
    transport = `git config git-media.transport`.chomp
    case transport
    when ""
      raise "git-media.transport not set"
    when "scp"
      user = `git config git-media.scpuser`.chomp
      host = `git config git-media.scphost`.chomp
      path = `git config git-media.scppath`.chomp
      port = `git config git-media.scpport`.chomp
      if user === ""
	raise "git-media.scpuser not set for scp transport"
      end
      if host === ""
	raise "git-media.scphost not set for scp transport"
      end
      if path === ""
	raise "git-media.scppath not set for scp transport"
      end
      GitMedia::Transport::Scp.new(user, host, path, port)

    when "local"
      path = `git config git-media.localpath`.chomp
      if path === ""
	raise "git-media.localpath not set for local transport"
      end
      GitMedia::Transport::Local.new(path)
    when "s3"
      bucket = `git config git-media.s3bucket`.chomp
      key = `git config git-media.s3key`.chomp
      secret = `git config git-media.s3secret`.chomp
      if bucket === ""
	raise "git-media.s3bucket not set for s3 transport"
      end
      if key === ""
	raise "git-media.s3key not set for s3 transport"
      end
      if secret === ""
	raise "git-media.s3secret not set for s3 transport"
      end
      GitMedia::Transport::S3.new(bucket, key, secret)
    when "atmos"
      require 'git-media/transport/atmos_client'
      endpoint = `git config git-media.endpoint`.chomp
      uid = `git config git-media.uid`.chomp
      secret = `git config git-media.secret`.chomp
      tag = `git config git-media.tag`.chomp

      if endpoint == ""
        raise "git-media.endpoint not set for atmos transport"
      end

      if uid == ""
        raise "git-media.uid not set for atmos transport"
      end

      if secret == ""
        raise "git-media.secret not set for atmos transport"
      end
      GitMedia::Transport::AtmosClient.new(endpoint, uid, secret, tag)
    else
      raise "Invalid transport #{transport}"
    end
  end

  def self.get_pull_transport
    self.get_transport
  end

  module Application
    def self.run!
      
      cmd = ARGV.shift # get the subcommand
      cmd_opts = case cmd
        when "filter-clean" # parse delete options
          require 'git-media/filter-clean'
          GitMedia::FilterClean.run!
        when "filter-smudge"
          require 'git-media/filter-smudge'
          GitMedia::FilterSmudge.run!
        when "clear" # parse delete options
          require 'git-media/clear'
          GitMedia::Clear.run!
        when "sync"
          require 'git-media/sync'
          GitMedia::Sync.run!
        when "download"
          require 'git-media/sync'
          GitMedia::Sync.run! :download_only => true
        when 'status'
          require 'git-media/status'
          Trollop::options do
            opt :force, "Force status"
          end
          GitMedia::Status.run!
        else
	  print <<EOF
usage: git media sync|download|status|clear

  sync     Sync files with remote server
  download Download files that are missing; don't upload any files
  status   Show files that are waiting to be uploaded and file size
  clear    Upload and delete the local cache of media files
EOF
        end
      
    end
  end
end
