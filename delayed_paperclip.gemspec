Gem::Specification.new do |s|
  s.name = %q{delayed_paperclip}
  s.version = "0.7.0"

  s.authors = ["Jesse Storimer"]
  s.summary = %q{Process your Paperclip attachments in the background with delayed_job or Resque.}
  s.description = %q{Process your Paperclip attachments in the background with delayed_job or Resque.}
  s.email = %q{jesse@jstorimer.com}
  s.homepage = %q{http://github.com/jstorimer/delayed_paperclip}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_runtime_dependency 'paperclip', ["~> 2.3.0"]

  s.add_development_dependency 'mocha'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'delayed_job'
  s.add_development_dependency 'resque'
end

