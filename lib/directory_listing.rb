require 'truncate'
require 'filesize'

# = Easy Apache-style directory listings for Sinatra.
#
# == Usage
#
# Directory_listing will return HTML, so the following is a complete Sinatra 
# app that will provide a directory listing of whatever path you navigate to:
#
# require 'directory_listing
#
# get '*' do |path|
# 	if File.exist?(File.join(settings.public_folder, path))
# 		"#{Directory_listing.list(
# 			:directory => path, 
# 			:sinatra_public => settings.public_folder,
# 			:stylesheet => "stylesheets/styles.css",
# 			:should_list_invisibles => "no",
# 			:last_modified_format => "%Y-%m-%d %H:%M:%S",
# 			:dir_html_style => "bold",
# 			:regfile_html_style => "none",
# 			:filename_truncate_length => 40)}"
# 	else
# 		not_found
# 	end
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
# dir_html_style # html style for directories - "bold", "italic", "underline", or "none" - defaults to "bold"
# regfile_html_style # html style for regular files - "bold", "italic", "underline", or "none" - defaults to "none"
# filename_truncate_length # (integer) length to truncate file names to - defaults to 40

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
		dir = File.join(options[:sinatra_public], options[:directory])

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
    if options[:dir_html_style]
      $dir_html_style = options[:dir_html_style]
    else
      $dir_html_style = "bold"
    end
    if options[:regfile_html_style]
      $regfile_html_style = options[:regfile_html_style]
    else
      $regfile_html_style = "none"
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
      html << wrap(file, dir)
    end
    html << "\n</table>\n"
		html << "</body>\n</html>\n"
    "#{html}"
  end
  
  private

  def self.m_time(file, dir)
    time = "#{File.mtime(File.join(dir, file)).strftime $last_modified_format}"
  end

  def self.size(file, dir)
    if File.directory?(File.join(dir, file))
      "-"
    else
      size = Filesize.from("#{File.stat(File.join(dir, file)).size} B").pretty
      "#{size}"
    end
  end

  def self.name(file, dir)
    html = pre_dir = post_dir = pre_reg = post_reg = ""
    tfile = file.truncate($filename_truncate_length, '...')

    case $dir_html_style
    when "bold"
      pre_dir = "<b>"
      post_dir = "</b>"
    when "italic"
      pre_dir = "<i>"
      post_dir = "</i>"
    when "underline"
      pre_dir = "<u>"
      post_dir = "</u>"
    else
      pre_dir = "<b>"
      post_dir = "</b>"
    end
    case $regfile_html_style
    when "bold"
      pre_reg = "<b>"
      post_reg = "</b>"
    when "italic"
      pre_reg = "<i>"
      post_reg = "</i>"
    when "underline"
      pre_reg = "<u>"
      post_reg = "</u>"
    else
      pre_reg = ""
      post_reg = ""
    end

    if File.directory?(File.join(dir, file))
      html << "<a href='#{file}'>#{pre_dir}#{tfile}#{post_dir}</a>"
    else
      html << "<a href='#{file}'>#{pre_reg}#{tfile}#{post_reg}"
    end
    "#{html}"
  end

  def self.wrap(file, dir)
    wrapped = ""
    if $should_list_invisibles == "yes"
      wrapped << "\n\t<tr>
      \t<td>#{name(file, dir)}</td>
      \t<td>#{m_time(file, dir)}</td>
      \t<td>#{size(file, dir)}</td>\n\t</tr>"
    else
      if file[0] != "."
        wrapped << "\n\t<tr>
        \t<td>#{name(file, dir)}</td>
        \t<td>#{m_time(file, dir)}</td>
        \t<td>#{size(file, dir)}</td>\n\t</tr>"
      end
    end
    "#{wrapped}"
  end
  
end
