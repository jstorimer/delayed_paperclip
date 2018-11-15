spec = Gem::Specification.new do |s|
  s.name        = %q{delayed_paperclip}
  s.version     = "2.4.5.1"

  s.authors     = ["Jesse Storimer", "Bert Goethals"]
  s.summary     = %q{Process your Paperclip attachments in the background.}
  s.description = %q{Process your Paperclip attachments in the background with delayed_job, Resque or your own processor.}
  s.email       = %q{jesse@jstorimer.com}
  s.homepage    = %q{http://github.com/jstorimer/delayed_paperclip}

  s.required_ruby_version = ">= 2.0.0"

  git_files = `git ls-files -z`.split("\x0")
  s.files       = git_files.reject { |f| f.match(%r{^(gemfiles|test)/}) }
  s.test_files  = git_files.select { |f| f.match(%r{^(gemfiles|test)/}) }

  s.add_dependency 'paperclip', [">= 2.2.9"]

  s.add_development_dependency 'mocha'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'delayed_job'
  s.add_development_dependency 'resque'
  s.add_development_dependency 'sidekiq'
end

