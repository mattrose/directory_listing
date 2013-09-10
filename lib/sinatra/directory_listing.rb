require 'sinatra/base'
require 'truncate'
require 'filesize'
require 'pathname'
require 'uri'
require 'erb'

module Sinatra
  module Directory_listing
    
    require_relative 'directory_listing/version.rb'
    require_relative 'directory_listing/layout.rb'
    require_relative 'directory_listing/resource.rb'
    require_relative 'directory_listing/page.rb'

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

      ##
      # Create a page object and start setting attributes.

      page = Page.new
      
      page.should_list_invisibles = options[:should_list_invisibles]
      page.last_modified_format = options[:last_modified_format]
      page.filename_truncate_length = options[:filename_truncate_length]      
      page.public_folder = settings.public_folder
      page.request_path = request.path
      page.request_params = request.params
      
      ##
      # Start generating strings to be injected into the erb template 
      
      page.current_page = URI.unescape(request.path)
      page.readme = options[:readme] if options[:readme]
      if options[:stylesheet]
        page.stylesheet = "<link rel='stylesheet' type='text/css' href='/#{options[:stylesheet].sub(/^[\/]*/,"")}'>"
      end
      
      ##
      # Generate the "back to" link
      # Append the sorting information if the current directory is sorted.
      
      if URI.unescape(request.path) != "/"
        back_link = Pathname.new(request.path).parent
        if page.request_params["sortby"] && page.request_params["direction"]
          back_link = back_link.to_s + "?sortby=" + page.request_params["sortby"] + "&direction=" + page.request_params["direction"]
        end
        page.back_to_link = "<a href='#{back_link}'>&larr; Parent directory</a>"
      else
        page.back_to_link = "<a>Root directory</a>"
      end
      
      ##
      # Get an array of files to be listed. 
      
      files = Array.new
      Dir.foreach(File.join(settings.public_folder, URI.unescape(request.path))) do |file|
        files.push(file)
      end

      ##
      # If the only thing in the array are invisible files, 
      # display a "No files" listing.
      
      page.files_html = ""
      if files == [".", ".."]
        page.files_html << "
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
          resources.push(Resource.new(resource, page))
        end
        
        ##
        # Get the sortby and direction parameters ("file" and "ascending", by 
        # default).

        page.sort_item = "file"
        page.sort_direction = "ascending"
        page.sort_item = page.request_params["sortby"] if page.request_params["sortby"]
        page.sort_direction = page.request_params["direction"] if page.request_params["direction"]
        
        ##
        # Sort the resources. 
        # The second and third arguments are what to sort by ("file", "mtime", 
        # or "size"), and whether to sort in order ("ascending") or reverse 
        # ("descending").
        
        sorted_resources = Resource.sort(resources, page.sort_item, page.sort_direction)
        
        ##
        # Set display variables and sort links based on sorting variables
        
        file_link_dir = mtime_link_dir = sortby_link_dir = "ascending"
        
        case page.sort_item
        when "file"
          page.sort_item_display = "alphabetically"
          case page.sort_direction
          when "ascending"
            page.sort_direction_display = ""
            file_link_dir = "descending"
          when "descending"
            page.sort_direction_display = "reversed"
            file_link_dir = "ascending"
          end
        when "mtime"
          page.sort_item_display = "by modification date"
          case page.sort_direction
          when "ascending"
            page.sort_direction_display = "oldest to newest"
            mtime_link_dir = "descending"
          when "descending"
            page.sort_direction_display = "newest to oldest"
            mtime_link_dir = "ascending"
          end
        when "size"
          page.sort_item_display = "by size"
          case page.sort_direction
          when "ascending"
            page.sort_direction_display = "smallest to largest"
            sortby_link_dir = "descending"
          when "descending"
            page.sort_direction_display = "largest to smallest"
            sortby_link_dir = "ascending"
          end
        end
        
        page.file_sort_link = "?sortby=file&direction=#{file_link_dir}"
        page.mtime_sort_link = "?sortby=mtime&direction=#{mtime_link_dir}"
        page.size_sort_link = "?sortby=size&direction=#{sortby_link_dir}"
        
        ##
        # Finally, generate the html from the array of Resources. 
        
        sorted_resources.each do |resource|
          page.files_html << resource.wrap
        end
      end
      
      ##
      # Generate and return the complete page from the erb template.  
      
      erb = ERB.new(LAYOUT)
      erb.result(binding)
    end
      
  end

  helpers Directory_listing
end
