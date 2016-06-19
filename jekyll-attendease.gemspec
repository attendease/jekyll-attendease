lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/attendease_plugin/version'

Gem::Specification.new do |s|
  s.name          = 'jekyll-attendease'
  s.version       = Jekyll::AttendeasePlugin::VERSION
  s.date          = '2016-05-01'
  s.summary       = 'Attendease event helper for Jekyll'
  s.description   = 'Bring your event data into Jekyll for amazing event websites.'
  s.authors       = [ 'Michael Wood', 'Patrick Gibson', 'Jamie Lubiner', 'Antoine Censi' ]
  s.email         = 'support@attendease.com'
  s.files         = (Dir.glob('lib/**/*.rb') + Dir.glob('templates/**/*.html'))
  s.test_files    = Dir.glob('spec/**/*.rb').grep(/^(test|spec|features)\//)
  s.require_paths = [ 'lib' ]

  s.homepage    = 'https://attendease.com/'
  s.licenses    = [ 'MIT' ]

  s.add_runtime_dependency 'httparty',  '~> 0.13.5'
  s.add_runtime_dependency 'json',      '~> 1.8.1'
  s.add_runtime_dependency 'i18n',      '~> 0.6.9'
  s.add_runtime_dependency 'redcarpet', '~> 2.3.0'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'jekyll', '1.5.1'
  s.add_development_dependency 'coveralls'

end
