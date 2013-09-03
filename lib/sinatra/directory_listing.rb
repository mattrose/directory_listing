require 'sinatra/base'
require 'truncate'
require 'filesize'
require 'pathname'
require 'uri'
require 'erb'

# ### directory_listing: easy, CSS-styled, Apache-like directory listings for Sinatra.
# 
# ### Install:
# 
# For regular use:
# 
# ```bash
# (sudo) gem install directory_listing
# ```
# 
# Or from source:
# 
# ```bash
# rake install
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
      # Set default options. 
      
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
      
      ##
      # Get the public folder, request path, and parameters and 
      # store in globals to be used by the Resource class.
      
      $public_folder = settings.public_folder
      $request_path = request.path
      $request_params = request.params
      
      ##
      # Start generating strings to be injected into the erb template 
      
      $current_page = URI.unescape(request.path)
      $readme = options[:readme] if options[:readme]
      if options[:stylesheet]
        $stylesheet = "<link rel='stylesheet' type='text/css' href='/#{options[:stylesheet].sub(/^[\/]*/,"")}'>"
      end
      
      ##
      # Generate the "back to" link
      # Append the sorting information if the current directory is sorted.
      
      if URI.unescape(request.path) != "/"
        back_link = Pathname.new(URI.unescape(request.path)).parent
        if $request_params["sortby"] && $request_params["direction"]
          back_link = back_link.to_s + "?sortby=" + $request_params["sortby"] + "&direction=" + $request_params["direction"]
        end
        $back_to_link = "<a href='#{back_link}'>&larr; Parent directory</a>"
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
      # If the only thing in the array are invisible files, display a "No files" listing.
      
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
        # Get the sortby and direction parameters ("file" and "ascending", by 
        # default).

        $sort_item = "file"
        $sort_direction = "ascending"
        $sort_item = $request_params["sortby"] if $request_params["sortby"]
        $sort_direction = $request_params["direction"] if $request_params["direction"]
        
        ##
        # Sort the resources. 
        # The second and third arguments are what to sort by ("file", "mtime", 
        # or "size"), and whether to sort in order ("ascending") or reverse 
        # ("descending").
        
        sorted_resources = Resource.sort(resources, $sort_item, $sort_direction)
        
        ##
        # Set display variables and sort links based on sorting variables
        
        file_link_dir = mtime_link_dir = sortby_link_dir = "ascending"
        
        case $sort_item
        when "file"
          $sort_item_display = "alphabetically"
          case $sort_direction
          when "ascending"
            $sort_direction_display = ""
            file_link_dir = "descending"
          when "descending"
            $sort_direction_display = "reversed"
            file_link_dir = "ascending"
          end
        when "mtime"
          $sort_item_display = "by modification date"
          case $sort_direction
          when "ascending"
            $sort_direction_display = "oldest to newest"
            mtime_link_dir = "descending"
          when "descending"
            $sort_direction_display = "newest to oldest"
            mtime_link_dir = "ascending"
          end
        when "size"
          $sort_item_display = "by size"
          case $sort_direction
          when "ascending"
            $sort_direction_display = "smallest to largest"
            sortby_link_dir = "descending"
          when "descending"
            $sort_direction_display = "largest to smallest"
            sortby_link_dir = "ascending"
          end
        end
        
        $file_sort_link = "?sortby=file&direction=#{file_link_dir}"
        $mtime_sort_link = "?sortby=mtime&direction=#{mtime_link_dir}"
        $size_sort_link = "?sortby=size&direction=#{sortby_link_dir}"
        
        ##
        # Finally, generate the html from the array of Resources. 
        
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
