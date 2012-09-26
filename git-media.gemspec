# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git-media}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Chacon"]
  s.date = %q{2009-06-10}
  s.default_executable = %q{git-media}
  s.email = %q{schacon@gmail.com}
  s.executables = ["git-media"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/git-media",
     "git-media.gemspec",
     "lib/git-media/clear.rb",
     "lib/git-media/filter-clean.rb",
     "lib/git-media/filter-smudge.rb",
     "lib/git-media/status.rb",
     "lib/git-media/sync.rb",
     "lib/git-media/transport",
     "lib/git-media/transport/local.rb",
     "lib/git-media/transport/s3.rb",
     "lib/git-media/transport/atmos_client.rb",
     "lib/git-media/transport/scp.rb",
     "lib/git-media/transport/drive.rb",
     "lib/git-media/transport.rb",
     "lib/git-media.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/schacon/git-media}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{"This is a summary! Stop yer whining"}

  s.add_dependency 'trollop'
  s.add_dependency 's3'
  s.add_dependency 'ruby-atmos-pure'
  s.add_dependency 'right_aws'
  s.add_development_dependency 'jeweler'
  s.add_development_dependency 'rspec'

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

