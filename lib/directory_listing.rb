require 'truncate'
require 'filesize'
require 'pathname'

# = Easy Apache-style directory listings for Sinatra.
#
# == Usage
#
# Directory_listing.list will return HTML, so the following is a complete Sinatra 
# app that will provide a directory listing of whatever path you navigate to
# and let you view any file that is served directly:
#
# require 'directory_listing
#
# get '*' do |path|
#   if File.exist?(File.join(settings.public_folder, path))
#     if File.directory?(File.join(settings.public_folder, path))
#       "#{Directory_listing.list(
#         :directory => path, 
#         :sinatra_public => settings.public_folder,
#       )}"
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
# Any option key may be omitted except for :directory and :sinatra_public. Explanations of options are below.
#
# == Options
#
# directory # the directory to list
# sinatra_public # sinatra's public folder - your public folder (and the default) is likely "settings.public_folder"
# stylesheet # pass a stylesheet to style the page with
# should_list_invisibles # should the directory listing include invisibles (dotfiles) - "yes" or "no"
# last_modified_format # format for last modified date (http://www.ruby-doc.org/core-2.0/Time.html) - defaults to "%Y-%m-%d %H:%M:%S"
# filename_truncate_length # (integer) length to truncate file names to - defaults to 40
#
# == Styling
#
# It's pretty easy to figure out how to style directory_listing by looking at the source. 
#
# Some gotchas:
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

module Directory_listing
  @@options = {}
    
  def self.options=(value)
    @@options = value
  end

  def self.options()
    @@options
  end
  
  def self.list(options)
    options = @@options.merge options
    raise(ArgumentError, ":directory is required") unless options[:directory]
    raise(ArgumentError, ":sinatra_public is required") unless options[:sinatra_public]
    pub = options[:sinatra_public]
    dir = File.join(pub, options[:directory])

    if options[:should_list_invisibles]
      $should_list_invisibles = options[:should_list_invisibles]
    else
      $should_list_invisibles = "no"
    end
    if options[:last_modified_format]
      $last_modified_format = options[:last_modified_format]
    else
      $last_modified_format = "%Y-%m-%d %H:%M:%S"
    end
    if options[:filename_truncate_length]
      $filename_truncate_length = options[:filename_truncate_length]
    else
      $filename_truncate_length = 40
    end
    
    html = "<html>\n<head>\n"
    if options[:stylesheet]
      html << "<link rel=\"stylesheet\" type=\"text/css\" href=\"/#{options[:stylesheet].sub(/^[\/]*/,"")}\">\n"
    end
    html << "</head>\n<body>\n"
    html << "<h1>Index of #{options[:directory]}</h1>\n"
    html << "<table>\n"
    html << "\t<tr>\n\t\t<th>File</th>\n\t\t<th>Last modified</th>\n\t\t<th>Size</th>\n\t</tr>"
    files = Array.new
    Dir.foreach(dir, &files.method(:push))
    files.sort.each do |file|
      html << wrap(file, dir, pub)
    end
    html << "\n</table>\n"
    html << "</body>\n</html>\n"
    "#{html}"
  end
  
  private

  def self.m_time(file, dir)
    time = "\t<td>#{File.mtime(File.join(dir, file)).strftime $last_modified_format}</td>"
  end

  def self.size(file, dir)
    if File.directory?(File.join(dir, file))
      "\t<td>-</td>"
    else
      size = Filesize.from("#{File.stat(File.join(dir, file)).size} B").pretty
      "\t<td>#{size}</td>"
    end
  end

  def self.name(file, dir, pub)
    tfile = file.truncate($filename_truncate_length, '...')
    link = Pathname.new(File.join(dir, file)).relative_path_from(Pathname.new(pub))
    
    html = ""
    if File.directory?(File.join(dir, file))
      html << "\t<td class='dir'><a href='#{link}'>#{tfile}</a></td>"
    else
      html << "\t<td class='file'><a href='#{link}'>#{tfile}</td>"
    end
    "#{html}"
  end

  def self.wrap(file, dir, pub)
    wrapped = ""
    if $should_list_invisibles == "yes"
      wrapped << "\n\t<tr>
      #{name(file, dir, pub)}
      #{m_time(file, dir)}
      #{size(file, dir)}\n\t</tr>"
    else
      if file[0] != "."
        wrapped << "\n\t<tr>
        #{name(file, dir, pub)}
        #{m_time(file, dir)}
        #{size(file, dir)}\n\t</tr>"
      end
    end
    "#{wrapped}"
  end
  
end
