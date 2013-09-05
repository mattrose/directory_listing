require 'sinatra'

require_relative '../lib/sinatra/directory_listing.rb'

get '/stylesheets' do 
  list({
    :stylesheet => "/stylesheets/styles.css"
  })
end

get '/readme' do 
  list({
    :readme => "this is my readme"
  })
end

get '/should_list_invisibles' do 
  list({
    :should_list_invisibles => true
  })
end

get '*' do |path|
  if File.exist?(File.join(settings.public_folder, path))
    if File.directory?(File.join(settings.public_folder, path))
      list()
    else
      send_file File.join(settings.public_folder, path)
    end 
  else
    not_found
  end 
end

not_found do
  'Try again.'
end
