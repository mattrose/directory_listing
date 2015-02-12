### directory_listing: easy, CSS-styled, Apache-like directory listings for Sinatra.

### Description

```directory_listing``` is a [Sinatra](http://sinatrarb.com) plugin that generates Apache-like directory listings. It was designed to be:

1. Easy to use and configure
2. Style-able with CSS
3. Embeddable 
4. Able to replicate all the features of Apache's directory listings including sorting

```directory_listing``` also includes a number of configuration options - see the [Options](#options) section below.

### Install

For regular use:

```bash
(sudo) gem install directory_listing
```

Or from source:

```bash
bundle install
rake install
```

### Usage

```list()``` will return HTML, so the following is a complete Sinatra app that will provide a directory listing of whatever path you navigate to and let you view any file that is served directly:

```ruby
require 'sinatra'
require 'sinatra/directory_listing'

get '*' do |path|
  if File.exist?(File.join(settings.public_folder, path))
    if File.directory?(File.join(settings.public_folder, path))
      list()
    else
      send_file File.join(settings.public_folder, path)
    end
  else
    not_found
  end
end

not_found do
  'Try again.'
end
```

### Options

Options are passed in a hash:

```ruby
list({
  :stylesheet => "stylesheets/styles.css",
  :readme => "<a>Welcome!</a>"
})
```

Available options:

- ```stylesheet``` - a stylesheet to style the generated directory listing with, relative to your ```public_folder```
- ```embed_in``` - an ```erb``` template in which to embed the directory listing, relative to your ```public_folder``` [(see below)](#embedding).
- ```readme``` - an HTML string that will be appended at the footer of the generated directory listing
- ```favicon``` - URL to a favicon
- ```should_list_invisibles``` - whether the directory listing should include invisibles (dotfiles) - true or false, defaults to false
- ```should_show_file_exts``` - whether the directory listing should show file extensions - true or false, defaults to true
- ```smart_sort``` - whether sorting should ignore "[Tt]he " at the beginning of filenames - true or false, defaults to true
- ```last_modified_format``` - [format](http://www.ruby-doc.org/core-2.0/Time.html) for last modified date - defaults to ```%Y-%m-%d %H:%M:%S```
- ```filename_truncate_length``` - length to truncate file names to - integer, defaults to 40

### Embedding

By default, ```directory_listing``` will generate a complete HTML page. However, you can use the ```embed_in``` option to pass in your own ```erb``` template. 
You should look at the [default template](lib/sinatra/directory_listing/layout.rb) to get an idea of the layout, but you should include the following:

- ```<%= page.current_page %>``` - the name of the current page
- ```<%= page.sort_item_display %>``` - how the page is currently sorted
- ```<%= page.sort_direction_display %>``` - the direction the items are sorted in 
- ```<%= page.favicon %>``` - the favicon
- ```<%= page.stylesheet %>``` - the stylesheet
- ```<%= page.nav_bar %>``` - the page's navigation bar
- ```<%= page.file_sort_link %>``` - link to sort by filename
- ```<%= page.mtime_sort_link %>``` - link to sort by mtime
- ```<%= page.size_sort_link %>``` - link to sort by size
- ```<%= page.files_html %>``` - the file listing
- ```<%= page.readme %>``` - the readme

If you want to embed the default file listing (but are passing a custom template to modify other attributes), you can use the following table:

```html
<table>
  <tr>
    <th><a href='<%= page.file_sort_link %>'>File</a></th>
    <th><a href='<%= page.mtime_sort_link %>'>Last modified</a></th>
    <th><a href='<%= page.size_sort_link %>'>Size</a></th>
  </tr>
  <%= page.files_html %>
</table>
<hr><hr>
```

NOTE: You should not put your ```erb``` template in a method as the gem does - you should be passing an actual ```.erb``` file to the ```embed_in``` option.

### Styling

It's pretty easy to figure out how to style ```directory_listing``` by looking at the source, but here are some gotchas:

- Every file is a ```<td>``` element in a table. Directories will have a class of ```dir``` and regular files will have a class of ```file```. 
- You can style the "File" column with this CSS:

```css
table tr > td:first-child { 
  text-align: left;
}
```

- "Last modified" column:

```css
table tr > td:first-child + td { 
  text-align: left;
}
```

- "Size" column:

```css
table tr > td:first-child + td + td { 
  text-align: left;
}
```

- The navigation bar is in a div called ```nav``` and consists of links embedded in ```h1``` tags:

```css
div.nav h1, div.nav a {
  font-size: 16px;
  font-weight: 600;
}
```

### Getting Help

The best way to report a bug or feature request is to [open an issue on GitHub](https://github.com/movesmyers/directory_listing/issues). 

Additionally, I'd love to hear your feedback about ```directory_listing``` through [Twitter](http://twitter.com/movesmyers) or [email](mailto:rick.myers@me.com).

### Changelog

Here are the latest [commits](https://github.com/movesmyers/directory_listing/commits/master).

### Contributing

1. Fork it
2. Create your feature branch: ```git checkout -b my-new-feature```
3. Commit your changes (remember to include a test!): ```git commit -am 'Add some feature'```
4. Push to the branch: ```git push origin my-new-feature```
5. Create new Pull Request

#### Note: 

Out of the box, the test suite will fail, as one of the tests tries to sort via mtime, and [git doesn't preserve mtimes](https://git.wiki.kernel.org/index.php/GitFaq#Why_isn.27t_Git_preserving_modification_time_on_files.3F). You'll want to touch those files in the following order to make them pass - ```2k.dat```, ```3k.dat```, ```1k.dat```.

### License

```directory_listing``` is licensed under the MIT license. See the LICENSE file for details.
