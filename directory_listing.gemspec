require File.join(Dir.pwd, 'lib/sinatra/directory_listing.rb')
require File.join(Dir.pwd, 'lib/sinatra/directory_listing/version.rb')

Gem::Specification.new do |s|
  s.name        = 'directory_listing'
  s.version     = Directory_listing::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "Easy, CSS-styled, Apache-like directory listings for Sinatra."
  s.description = "A Sinatra extension for generating easy, CSS-styled, Apache-like directory listings."
  s.authors     = ["Richard Myers"]
  s.email       = 'rick.myers@me.com'
  s.license     = 'WTFPL'
  s.files       = ["lib/sinatra/directory_listing.rb"]
  s.homepage    = 'https://rubygems.org/gems/directory_listing'
  
  s.add_dependency 'filesize', '>=0.0.2'
  s.add_dependency 'truncate', '>=0.0.4'
  
  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
end
 
