require 'sinatra/base'
require 'truncate'
require 'filesize'
require 'pathname'

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
# should_list_invisibles # whether the directory listing should include invisibles (dotfiles) - "yes" or "no"
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
    
    private
    
    def m_time(file)
      f = File.join(File.join(settings.public_folder, request.fullpath), file)
      "\t<td>#{File.mtime(f).strftime $last_modified_format}</td>"
    end
    
    def size(file)
      f = File.join(File.join(settings.public_folder, request.fullpath), file)
      if File.directory?(f)
        "\t<td>-</td>"
      else
        size = Filesize.from("#{File.stat(f).size} B").pretty
        "\t<td>#{size}</td>"
      end
    end
    
    def name(file)
      tfile = file.truncate($filename_truncate_length, '...')
      if (Pathname.new(request.path).cleanpath).eql?((Pathname.new(settings.public_folder)).cleanpath)
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
      "#{html}"
    end
    
    def wrap(file)
      wrapped = ""
      if $should_list_invisibles == "yes"
        wrapped << "\n\t<tr>
        #{name(file)}
        #{m_time(file)}
        #{size(file)}\n\t</tr>"
      else
        if file[0] != "."
          wrapped << "\n\t<tr>
          #{name(file)}
          #{m_time(file)}
          #{size(file)}\n\t</tr>"
        end
      end
      "#{wrapped}"
    end
            
    def list(o={})
      options = {
        :should_list_invisibles => "no",
        :last_modified_format => "%Y-%m-%d %H:%M:%S",
        :filename_truncate_length => 40,
        :stylesheet => "",
        :readme => ""
      }.merge(o)
      
      $should_list_invisibles = options[:should_list_invisibles]
      $last_modified_format = options[:last_modified_format]
      $filename_truncate_length = options[:filename_truncate_length]
      
      html = "<html>\n<head>\n"
      html << "<title>Index of #{request.path}</title>\n"
      html << "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>\n"
      if options[:stylesheet]
        html << "<link rel=\"stylesheet\" type=\"text/css\" href=\"/#{options[:stylesheet].sub(/^[\/]*/,"")}\">\n"
      end
      html << "</head>\n<body>\n"
      html << "<h1>Index of #{request.path}</h1>\n"
      if request.path != "/"
        html << "<a href='#{Pathname.new(request.path).parent}'>&larr; Parent directory</a><br><br>"
      else
        html << "<a>Root directory</a><br><br>"
      end
      html << "<table>\n"
      html << "\t<tr>\n\t\t<th>File</th>\n\t\t<th>Last modified</th>\n\t\t<th>Size</th>\n\t</tr>\n"
      files = Array.new
      Dir.foreach(File.join(settings.public_folder, request.path), &files.method(:push))
      if files == [".", ".."]
        html << "\t<tr>\n\t\t<th>No files.</th>\n\t\t<th>-</th>\n\t\t<th>-</th>\n\t</tr>"
      else
        files.sort.each do |file|
          html << wrap(file)
        end
      end
      html << "\n</table>\n"
      html << "<br>\n#{options[:readme]}\n" if options[:readme]
      html << "</body>\n</html>\n"
      "#{html}"
    end
      
  end

  helpers Directory_listing
end