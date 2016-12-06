# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'pHash'
  s.version     = '1.1.5'
  s.summary     = %q{Use pHash with ruby}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'GPLv3'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w[lib]

  s.add_dependency 'ffi', '~> 1.0'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  
  if Gem::Platform.local.os == "darwin"
    s.post_install_message = "If you do not have pHash library installed yet, run this:\n\tbrew install --without-video-hash homebrew/boneyard/phash"
  end
  
end
