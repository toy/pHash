# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'pHash'
  s.version     = '1.2.1'
  s.summary     = %q{Use pHash with ruby}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'GPLv3'

  s.rubyforge_project = s.name

  s.metadata = {
    'bug_tracker_uri'   => "https://github.com/toy/#{s.name}/issues",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'source_code_uri'   => "https://github.com/toy/#{s.name}",
  }

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w[lib]

  s.add_dependency 'ffi', '~> 1.0'

  s.add_development_dependency 'rspec', '~> 3.0'

  if Gem::Platform.local.os == 'darwin'
    s.post_install_message = "pHash library can be installed using macports or brew:
\tport install pHash
\tbrew install --without-video-hash homebrew/boneyard/phash"
  end
end
