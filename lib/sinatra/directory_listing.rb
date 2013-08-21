require 'sinatra/base'
require 'truncate'
require 'filesize'
require 'pathname'
require 'uri'
require 'erb'

# = Easy, CSS-styled, Apache-like directory listings for Sinatra.
#
# == Usage
#
# list() will return HTML, so the following is a complete Sinatra 
# app that will provide a directory listing of whatever path you navigate to
# and let you view any file that is served directly:
#
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
#
# == Options
# 
# Options are passed in a hash:
# 
# list({
#   :stylesheet => "stylesheets/styles.css",
#   :readme => "<a>Welcome!</a>"
# })
#
# Available options:
#
# stylesheet # a stylesheet that will be added to the <head> of the generated directory listing
# readme # an HTML string that will be appended at the footer of the generated directory listing
# should_list_invisibles # whether the directory listing should include invisibles (dotfiles) - true or false, defaults to false
# last_modified_format # format for last modified date (http://www.ruby-doc.org/core-2.0/Time.html) - defaults to "%Y-%m-%d %H:%M:%S"
# filename_truncate_length # (integer) length to truncate file names to - defaults to 40
#
# == Styling
#
# It's pretty easy to figure out how to style directory_listing by looking at the source, but here are some gotchas:
#
# Every item listed is a <td> element in a table. Directories will have a class of "dir" and regular files will have a class of "file". 
#
# You can style the "File" column with this CSS:
# 
# table tr > td:first-child { 
#   text-align: left;
# }
# 
# Second column:
# table tr > td:first-child + td { 
#   text-align: left;
# }
# 
# Third column:
# table tr > td:first-child + td + td { 
#   text-align: left;
# }

module Sinatra
  module Directory_listing
    
    ##
    # erb template for page
    
    def template
      "<html>
      <head>
        <title>Index of <%= $current_page %></title>
        <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
        <%= $stylesheet %>
      </head>
      <body>
        <h1>Index of <%= $current_page %></h1>
        <%= $back_to_link %>
        <br><br>
  
        <table>
          <tr>
            <th>File</th>
            <th>Last modified</th>
            <th>Size</th>
          </tr>
          <%= $files_html %>
        </table>
  
        <br>
        <a><%= $readme if $readme %></a>
      </body>
      </html>"
    end
    
    ##
    # Get the mtime for a file. 
    
    def m_time(file)
      f = File.join(File.join(settings.public_folder, URI.unescape(request.fullpath)), file)
      "\t<td>#{File.mtime(f).strftime $last_modified_format}</td>"
    end
    
    ##
    # Get the size for a file. 
    
    def size(file)
      f = File.join(File.join(settings.public_folder, URI.unescape(request.fullpath)), file)
      if File.directory?(f)
        "\t<td>-</td>"
      else
        size = Filesize.from("#{File.stat(f).size} B").pretty
        "\t<td>#{size}</td>"
      end
    end
    
    ##
    # Get the name of a file. 
    
    def name(file)
      file = URI.unescape(file)
      tfile = file.truncate($filename_truncate_length, '...')
      if (Pathname.new(URI.unescape(request.path)).cleanpath).eql?((Pathname.new(settings.public_folder)).cleanpath)
        link = file
      else
        link = File.join(request.fullpath, file)
      end
    
      html = ""
      if File.directory?(File.join(settings.public_folder, link))
        html << "\t<td class='dir'><a href='#{link}'>#{tfile}</a></td>"
      else
        html << "\t<td class='file'><a href='#{link}'>#{tfile}</a></td>"
      end
      html
    end
    
    ##
    # Generate a single row of data for a file.
    
    def wrap(file)
      html = ""
      if $should_list_invisibles == true
        html << "\n\t<tr>
        #{self.name(file)}
        #{self.m_time(file)}
        #{self.size(file)}\n\t</tr>"
      else
        if file[0] != "."
          html << "\n\t<tr>
          #{self.name(file)}
          #{self.m_time(file)}
          #{self.size(file)}\n\t</tr>"
        end
      end
      html
    end
    
    ##
    # Generate the page.
    
    def list(o={})
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
      # Start generating strings to be injected into the erb template 
      
      $current_page = URI.unescape(request.path)
      $readme = options[:readme] if options[:readme]
      $stylesheet = "<link rel='stylesheet' type='text/css' href='/#{options[:stylesheet].sub(/^[\/]*/,"")}'>" if options[:stylesheet]
      
      if URI.unescape(request.path) != "/"
        $back_to_link = "<a href='#{Pathname.new(URI.unescape(request.path)).parent}'>&larr; Parent directory</a>"
      else
        $back_to_link = "<a>Root directory</a>"
      end
      
      $files_html = ""
      files = Array.new
      Dir.foreach(File.join(settings.public_folder, URI.unescape(request.path)), &files.method(:push))
      if files == [".", ".."]
        $files_html << "\t<tr>\n\t\t<th>No files.</th>\n\t\t<th>-</th>\n\t\t<th>-</th>\n\t</tr>"
      else
        files.sort.each do |file|
          $files_html << self.wrap(file)
        end
      end
      
      ##
      # Generate and return the complete page from the erb template.  
      
      erb = ERB.new(template)
      erb.result
    end
      
  end

  helpers Directory_listing
end
