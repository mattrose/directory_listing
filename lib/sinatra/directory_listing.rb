require 'sinatra/base'
require 'truncate'
require 'filesize'
require 'pathname'
require 'uri'
require 'erb'

# ### directory_listing: easy, CSS-styled, Apache-like directory listings for Sinatra.
# 
# ### Build from source:
# 
# ```bash
# gem build directory_listing.gemspec
# sudo gem install ./directory_listing-x.x.x.gem
# ```
# 
# ### Usage:
# 
# ```list()``` will return HTML, so the following is a complete Sinatra app that will provide a directory listing of whatever path you navigate to and let you view any file that is served directly:
# 
# ```ruby
# require 'sinatra'
# require 'sinatra/directory_listing'
# 
# get '*' do |path|
#   if File.exist?(File.join(settings.public_folder, path))
#     if File.directory?(File.join(settings.public_folder, path))
#       list()
#     else
#       send_file File.join(settings.public_folder, path)
#     end
#   else
#     not_found
#   end
# end
# 
# not_found do
#   'Try again.'
# end
# ```
# 
# ### Options:
# 
# Options are passed in a hash:
# 
# ```ruby
# list({
#   :stylesheet => "stylesheets/styles.css",
#   :readme => "<a>Welcome!</a>"
# })
# ```
# 
# Available options:
# 
# - ```stylesheet``` - a stylesheet that will be added to the <head> of the generated directory listing
# - ```readme``` - an HTML string that will be appended at the footer of the generated directory listing
# - ```should_list_invisibles``` - whether the directory listing should include invisibles (dotfiles) - true or false, defaults to false
# - ```last_modified_format``` - [format](http://www.ruby-doc.org/core-2.0/Time.html) for last modified date - defaults to ```%Y-%m-%d %H:%M:%S```
# - ```filename_truncate_length``` - (integer) length to truncate file names to - defaults to 40
# 
# ### Styling:
# 
# It's pretty easy to figure out how to style ```directory_listing``` by looking at the source, but here are some gotchas:
# 
# - Every item listed is a ```<td>``` element in a table. Directories will have a class of ```dir``` and regular files will have a class of ```file```. 
# - You can style the "File" column with this CSS:
# 
# ```css
# table tr > td:first-child { 
#   text-align: left;
# }
# ```
# 
# - "Last modified" column:
# 
# ```css
# table tr > td:first-child + td { 
#   text-align: left;
# }
# ```
# 
# - "Size" column:
# 
# ```css
# table tr > td:first-child + td + td { 
#   text-align: left;
# }
# ```

module Sinatra
  module Directory_listing
    
    require_relative 'directory_listing/version.rb'
    require_relative 'directory_listing/layout.rb'
    require_relative 'directory_listing/resource.rb'
    
    ##
    # Generate the page.
    
    def list(o={})
      
      ##
      # Set options. 
      options = {
        :should_list_invisibles => false,
        :last_modified_format => "%Y-%m-%d %H:%M:%S",
        :filename_truncate_length => 40,
        :stylesheet => "",
        :readme => ""
      }.merge(o)
      $should_list_invisibles = options[:should_list_invisibles]
      $last_modified_format = options[:last_modified_format]
      $filename_truncate_length = options[:filename_truncate_length]
      
      $public_folder = settings.public_folder
      $request_path = request.path
      $request_fullpath = request.fullpath
      
      ##
      # Start generating strings to be injected into the erb template 
      
      $current_page = URI.unescape(request.path)
      $readme = options[:readme] if options[:readme]
      $stylesheet = "<link rel='stylesheet' type='text/css' href='/#{options[:stylesheet].sub(/^[\/]*/,"")}'>" if options[:stylesheet]
      
      if URI.unescape(request.path) != "/"
        $back_to_link = "<a href='#{Pathname.new(URI.unescape(request.path)).parent}'>&larr; Parent directory</a>"
      else
        $back_to_link = "<a>Root directory</a>"
      end
      
      ##
      # Get an array of files to be listed. 
      
      files = Array.new
      Dir.foreach(File.join(settings.public_folder, URI.unescape(request.path))) do |file|
        files.push(file)
      end

      ##
      # If the only thing in the array are invisible files, display a "No files" message.
      
      $files_html = ""
      if files == [".", ".."]
        $files_html << "
          <tr>
            <th>No files.</th>
            <th>-</th>
            <th>-</th>
          </tr>"
      else
        
        ##
        # Otherwise, create an array of Resources:
        
        resources = Array.new
        Dir.foreach(File.join(settings.public_folder, URI.unescape(request.path))) do |resource|
          resources.push(Resource.new(resource))
        end
        
        ##
        # TODO: sort the resources. 
        
        sorted_resources = Resource.sort(resources, nil, nil)

        ##
        # Finally, generate the html of the list.
        
        sorted_resources.each do |resource|
          $files_html << resource.wrap
        end
      end
      
      ##
      # Generate and return the complete page from the erb template.  
      
      erb = ERB.new(LAYOUT)
      erb.result
    end
      
  end

  helpers Directory_listing
end
