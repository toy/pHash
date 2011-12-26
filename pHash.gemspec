# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'pHash'
  s.version     = '1.0.2'
  s.summary     = %q{Use pHash with ruby}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fspath'
end
