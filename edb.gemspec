Kernel.load 'lib/edb/version.rb'

Gem::Specification.new { |s|
  s.name        = 'edb'
  s.version     = EDB::VERSION
  s.author      = 'Giovanni Capuano'
  s.email       = 'webmaster@giovannicapuano.net'
  s.homepage    = 'http://github.com/RoxasShadow/edb'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'A framework to make and manage backups of your database.'
  s.description = 'EDB aims to be a framework to make and manage backups of your database.'
  s.license     = 'BSD'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'aws-sdk', '1.59.1'
  s.add_dependency 'ftp_sync', '~> 0.4'
}
