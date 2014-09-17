require 'git-media/status'

module GitMedia
  module UpdateIndex
    def self.run!
      puts 'update index'
      refs = GitMedia::Status.find_references

      `git update-index --assume-unchanged -- #{refs[:expanded].join(' ')}`
    end
  end
end
