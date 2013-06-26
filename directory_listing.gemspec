Gem::Specification.new do |s|
	s.name				= 'directory_listing'
	s.version			= '0.0.6'
	s.date				= '2013-06-25'
	s.summary			= "Easy, CSS-styled, Apache-like directory listings for Sinatra."
	s.description = "A gem to use with Sinatra for generating easy, CSS-styled, Apache-like directory listings."
	s.authors			= ["Richard Myers"]
	s.email				= 'rick.myers@me.com'
	s.files				= ["lib/directory_listing.rb"]
	s.homepage		= 'https://rubygems.org/gems/directory_listing'
	
	s.add_dependency 'filesize', '>=0.0.2'
	s.add_dependency 'truncate', '>=0.0.4'
end
 
