module Sinatra
  module Directory_listing
    
    LAYOUT = <<-EOF
<html>
<head>
  <title>Index of <%= page.current_page %>, sorted <%= page.sort_item_display %> <%= page.sort_direction_display %></title>
  <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
  <link rel='shortcut icon' href='<%= page.favicon %>'>
  <%= page.stylesheet %>
</head>
<body>
  <div class="nav">
    <h1><%= page.nav_bar %></h1>
  </div>

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

