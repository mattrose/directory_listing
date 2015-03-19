class Resource
 
  require_relative 'page.rb'

  ##
  # Class definition for a single resource to be listed. 
  # Each resource object has accessors for its file name, regular name, 
  # sortable name (removing "[Tt]he") size and mtime, as well as those 
  # components wrapped in html. 

  attr_accessor :file, :page, :sort_name, :name_html, :mtime, :mtime_html, :size, :size_html
  
  def initialize(file, page)
    @page = page
    @file = file
    @sort_name = file.gsub(/^[Tt]he /,"")
    @name_html = set_name(file)
    @mtime, @mtime_html = set_mtime(file)
    @size, @size_html = set_size(file)
  end
    
  ##
  # Set the mtime for a file. 
  #
  # Returns the mtime as a Time object so it can be sorted.

  def set_mtime(file)
    f = File.join(File.join(@page.public_folder, URI.unescape(@page.request_path)), file)
    html = "\t<td>#{File.mtime(f).strftime(@page.last_modified_format)}</td>"
    return [File.mtime(f), html]
  end

  ##
  # Set the size for a file. 
  #
  # Returns the size as number.

  def set_size(file)
    html = ""
    size = ''
    f = File.join(File.join(@page.public_folder, URI.unescape(@page.request_path)), file)
    if File.directory?(f)
      size = 0
      html = "\t<td>-</td>"
    else
      size = File.stat(f).size
      converted = Filesize.from("#{File.stat(f).size} B").pretty
      html = "\t<td>#{converted}</td>"
    end
    return [size, html]
  end

  ##
  # Set the name of the file and its link.

  def set_name(file)

    ##
    # Make sure we're working with an unescaped file name.
    # Remove the extension if neccesary and truncate it.
    # URI.unescape seems to work best to decode uris. 

    file = URI.unescape(file).force_encoding("utf-8")
    file_noext = file.gsub(File.extname(file), "") if @page.should_show_file_exts == false
    if file_noext
      file_truncated = file_noext.truncate(@page.filename_truncate_length, '...')
    else
      file_truncated = file.truncate(@page.filename_truncate_length, '...')
    end

    ##
    # If the requested resource is in the root public directory, the link is 
    # just the resource itself without the public directory path as well. 

    requested = Pathname.new(URI.unescape(@page.request_path)).cleanpath
    pub_folder = Pathname.new(@page.public_folder).cleanpath
    if requested.eql?(pub_folder)
      link = file
    else
      link = File.join(@page.request_path, file)
    end

    ##
    # Add a class of "dir" to directories and "file" to files.

    html = ""
    if File.directory?(URI.unescape(File.join(@page.public_folder, link)))
      html << "\t<td class='dir'>"
      
      ##
      # Append the sorting information if the current directory is sorted
      
      if @page.request_params["sortby"] && @page.request_params["direction"]
        link << "?sortby=" + @page.request_params["sortby"] + "&direction=" + @page.request_params["direction"]
      end
    else
      html << "\t<td class='file'>"
    end

    ##
    # Append the rest of the html. 
    # 
    # I haven't found a URI escaping library that will handle this
    # gracefully, so for now, we're going to just take care of spaces and 
    # apostrophes ourselves. 

    link = link.gsub(" ", "%20").gsub("'", "%27")
    html << "<a href='#{link}'>#{file_truncated}</a></td>"
    
    return html
  end

  ##
  # Generate html for a resource.
  
  def wrap
    html = ""
    if @page.should_list_invisibles == true
      html << "\n\t<tr>
      #{@name_html}
      #{@mtime_html}
      #{@size_html}
      \t</tr>"
    else
      if @file[0] != "."
        html << "\n\t<tr>
        #{@name_html}
        #{@mtime_html}
        #{@size_html}
        </tr>"
      end
    end
    html
  end
  
  ##
  # Sort an array of resources by name, mtime, or size. 
  # Direction should be "ascending" or "descending"
  
  def self.sort(resource_array, sortby, direction)
    sortby = "sort_name" if resource_array[0].page.smart_sort == true #and sortby = "file"
    new_array = resource_array.sort_by {|a| a.send(sortby)}
    new_array.reverse! if direction == "descending"
    new_array
  end

end
