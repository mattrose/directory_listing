module Sinatra
  module Directory_listing
    
    LAYOUT = <<-EOF
<html>
<head>
  <title>Index of <%= page.current_page %>, sorted <%= page.sort_item_display %> <%= page.sort_direction_display %></title>
  <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
  <%= page.stylesheet %>
</head>
<body>
  <h1><%= page.back_to_link %></h1>

  <table>
    <tr>
      <th><a href='<%= page.file_sort_link %>'>File</a></th>
      <th><a href='<%= page.mtime_sort_link %>'>Last modified</a></th>
      <th><a href='<%= page.size_sort_link %>'>Size</a></th>
    </tr>
    <%= page.files_html %>
  </table>

  <br>
  <a><%= page.readme %></a>
</body>
</html>
    EOF
    
  end
end

