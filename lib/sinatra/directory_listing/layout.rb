module Sinatra
  module Directory_listing
    
    LAYOUT = <<-EOF
<html>
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
      <th><a href='#name'>File</a></th>
      <th><a href='#mtime'>Last modified</a></th>
      <th><a href='#size'>Size</a></th>
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
