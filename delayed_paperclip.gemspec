Gem::Specification.new do |s|
  s.name = %q{delayed_paperclip}
  s.version = "0.7.2"

  s.authors = ["Jesse Storimer", "Bert Goethals"]
  s.summary = %q{Process your Paperclip attachments in the background.}
  s.description = %q{Process your Paperclip attachments in the background with delayed_job, Resque or your own processor.}
  s.email = %q{jesse@jstorimer.com}
  s.homepage = %q{http://github.com/jstorimer/delayed_paperclip}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_runtime_dependency 'paperclip', ["~> 2.3.9"]

  s.add_development_dependency 'mocha'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'delayed_job'
  s.add_development_dependency 'resque'
end

