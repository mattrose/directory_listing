class Page 

  ##
  # Class definition for the page to be generated.

  attr_accessor :should_list_invisibles,
                :should_show_file_exts,
                :smart_sort,
                :last_modified_format, 
                :filename_truncate_length, 
                :stylesheet,
                :favicon,
                :readme,
                :embed_in,
                :public_folder,
                :request_path,
                :request_params,
                :request_params_display,
                :current_page,
                :files_html,
                :sort_item,
                :sort_item_display,
                :sort_direction,
                :sort_direction_display,
                :file_sort_link,
                :mtime_sort_link,
                :size_sort_link, 
                :nav_bar

  ##
  # Get URL-appendable (Hash -> String) parameters for a request

  def request_params_display
    params = ""
    if self.request_params["sortby"] && self.request_params["direction"]
      params = "?sortby=" + self.request_params["sortby"] + "&direction=" + self.request_params["direction"]
    end
  end
  
  ##
  # Generate the page's navigation bar
  
  def nav_bar
    path_array = self.current_page.split("/").drop(1)
    path_count = path_array.count
    params = self.request_params_display
  
    if URI.unescape(self.current_page) == "/"
      nav_bar = "Index of /"
    else
      nav_bar = "Index of <a href=\'/#{params}'>/</a>"
    end
      
    previous_path = ""
    0.upto(path_array.count - 1) do |a|
      
      ##
      # Get escaped versions of this path and previous path
      
      escaped_path = path_array[a].gsub(" ", "%20").gsub("'", "%27")
      escaped_previous = previous_path.gsub(" ", "%20").gsub("'", "%27")
      
      ##
      # If this is the last directory in the path, it shouldn't have a link
      
      if a == path_array.count - 1
        href = ""
      else
        href = "<a href=\'/#{escaped_previous}#{escaped_path}#{params}\'>"
      end
      
      ##
      # If this is the first directory above the root, don't prepend a slash
      
      if a == 0 
      nav_bar << " #{href}#{path_array[a]}</a>"
      else
        nav_bar << " / #{href}#{path_array[a]}</a>"
      end
      
      previous_path << path_array[a] + "/"
    end
    
    @nav_bar = nav_bar
    
  end
  
  ##
  # Return sorting information given an item and the sorting direction

  def sorting_info(s_item, s_direction)

    file_link_dir = mtime_link_dir = sortby_link_dir = "ascending"
    s_item_display = s_direction_display = ""
    
    case s_item
    when "file"
      s_item_display = "alphabetically"
      case s_direction
      when "ascending"
        s_direction_display = ""
        file_link_dir = "descending"
      when "descending"
        s_direction_display = "reversed"
        file_link_dir = "ascending"
      end
    when "mtime"
      s_item_display = "by modification date"
      case s_direction
      when "ascending"
        s_direction_display = "oldest to newest"
        mtime_link_dir = "descending"
      when "descending"
        s_direction_display = "newest to oldest"
        mtime_link_dir = "ascending"
      end
    when "size"
      s_item_display = "by size"
      case s_direction
      when "ascending"
        s_direction_display = "smallest to largest"
        sortby_link_dir = "descending"
      when "descending"
        s_direction_display = "largest to smallest"
        sortby_link_dir = "ascending"
      end
    end
    
    return  "?sortby=file&direction=#{file_link_dir}",
            "?sortby=mtime&direction=#{mtime_link_dir}",
            "?sortby=size&direction=#{sortby_link_dir}",
            s_item_display,
            s_direction_display
    
  end

end
