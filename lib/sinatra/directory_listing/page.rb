class Page 

  ##
  # Class definition for the page to be generated.

  attr_accessor :should_list_invisibles, 
                :last_modified_format, 
                :filename_truncate_length, 
                :stylesheet,
                :readme,
                :public_folder,
                :request_path,
                :request_params,
                :current_page,
                :back_to_link,
                :files_html,
                :sort_item,
                :sort_item_display,
                :sort_direction,
                :sort_direction_display,
                :file_sort_link,
                :mtime_sort_link,
                :size_sort_link

  ##
  # Return new parameters for another location with the 
  # same sorting parameters as the passed Page object

  def sorted_url(page)
    params = ""
    if page.request_params["sortby"] && page.request_params["direction"]
      params = "?sortby=" + page.request_params["sortby"] + "&direction=" + page.request_params["direction"]
    end
  end

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
