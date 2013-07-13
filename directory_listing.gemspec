Gem::Specification.new do |s|
	s.name				= 'directory_listing'
	s.version			= '0.1.2'
	s.date				= '2013-07-13'
	s.summary			= "Easy, CSS-styled, Apache-like directory listings for Sinatra."
	s.description = "A Sinatra extension for generating easy, CSS-styled, Apache-like directory listings."
	s.authors			= ["Richard Myers"]
	s.email				= 'rick.myers@me.com'
	s.files				= ["lib/sinatra/directory_listing.rb"]
	s.homepage		= 'https://rubygems.org/gems/directory_listing'
	
	s.add_dependency 'filesize', '>=0.0.2'
	s.add_dependency 'truncate', '>=0.0.4'
end
 
