module Sinatra
  module Directory_listing
    
    LAYOUT = <<-EOF
<html>
<head>
  <title>Index of <%= $current_page %>, sorted <%= $sort_item_display %> <%= $sort_direction_display %></title>
  <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
  <%= $stylesheet %>
</head>
<body>
  <h1>Index of <%= $current_page %></h1>
  <%= $back_to_link %>
  <br><br>

  <table>
    <tr>
      <th><a href='<%= $file_sort_link %>'>File</a></th>
      <th><a href='<%= $mtime_sort_link %>'>Last modified</a></th>
      <th><a href='<%= $size_sort_link %>'>Size</a></th>
    </tr>
    <%= $files_html %>
  </table>

  <br>
  <a><%= $readme if $readme %></a>
</body>
</html>
    EOF
    
  end
end
