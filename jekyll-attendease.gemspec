Gem::Specification.new do |s|
  s.name        = 'jekyll-attendease'
  s.version     = '0.3.9'
  s.date        = '2013-09-03'
  s.summary     = "Attendease event helper for Jekyll"
  s.description = "Bring your event data into Jekyll for amazing event websites."
  s.authors     = ["Michael Wood", "Patrick Gibson", "Jamie Lubiner"]
  s.email       = 'support@attendease.com'
  s.files       = ["README.md", "lib/jekyll-attendease.rb", "assets/auth_check.js"]
  s.homepage    = 'https://attendease.com/'

  s.add_dependency 'httparty'#, '~> 0.11.0'
  s.add_dependency 'json'#, '~> 1.7.7'
end
