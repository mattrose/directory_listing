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
        :should_show_file_exts => true,
        :smart_sort => true,
        :last_modified_format => "%Y-%m-%d %H:%M:%S",
        :filename_truncate_length => 40,
        :stylesheet => "",
        :embed_in => "",
        :favicon => "",
        :readme => ""
      }.merge(o)

      ##
      # Create a page object and start setting attributes.

      page = Page.new
      page.should_list_invisibles = options[:should_list_invisibles]
      page.should_show_file_exts = options[:should_show_file_exts]
      page.smart_sort = options[:smart_sort]
      page.last_modified_format = options[:last_modified_format]
      page.filename_truncate_length = options[:filename_truncate_length]
      page.public_folder = settings.public_folder
      page.request_path = request.path
      page.request_params = request.params
      page.current_page = URI.unescape(request.path)
      
      ##
      # Set the erb template to embed in, the readme, stylesheet, and favicon
     
      page.readme = options[:readme] if options[:readme]
      page.favicon = options[:favicon] if options[:favicon]
      if options[:embed_in]
        page.embed_in = options[:embed_in]
      end
      if options[:stylesheet]
        page.stylesheet = "<link rel='stylesheet' type='text/css' href='/#{options[:stylesheet].sub(/^[\/]*/,"")}'>"
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
        # Get the sortby and direction parameters 
        # ("file" and "ascending" by default).

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
        
        page.file_sort_link,
        page.mtime_sort_link,
        page.size_sort_link,
        page.sort_item_display,
        page.sort_direction_display = 
          page.sorting_info(page.sort_item, page.sort_direction)

        ##
        # Finally, generate the html from the array of Resources. 
        
        sorted_resources.each do |resource|
          page.files_html << resource.wrap
        end
      end
      
      ##
      # Generate and return the complete page from the erb template.  
      
      if !page.embed_in.empty?
        path = File.join(settings.public_folder, page.embed_in)
        if File.exists?(path)
          erb = ERB.new(IO.read(path).force_encoding("utf-8"))
        else
          erb = ERB.new(LAYOUT)
        end
      else
        erb = ERB.new(LAYOUT)
      end
      erb.result(binding)
    end
      
  end

  helpers Directory_listing
end
