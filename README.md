### directory_listing: easy, CSS-styled, Apache-like directory listings for Sinatra.

### Build from source:

```bash
gem build directory_listing.gemspec
sudo gem install ./directory_listing-x.x.x.gem
```

### Usage:

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

### Options:

Options are passed in a hash:

```ruby
list({
  :stylesheet => "stylesheets/styles.css",
  :readme => "<a>Welcome!</a>"
})
```

Available options:

- ```stylesheet``` - a stylesheet that will be added to the <head> of the generated directory listing
- ```readme``` - an HTML string that will be appended at the footer of the generated directory listing
- ```should_list_invisibles``` - whether the directory listing should include invisibles (dotfiles) - true or false, defaults to false
- ```last_modified_format``` - [format](http://www.ruby-doc.org/core-2.0/Time.html) for last modified date - defaults to ```%Y-%m-%d %H:%M:%S```
- ```filename_truncate_length``` - (integer) length to truncate file names to - defaults to 40

### Styling:

It's pretty easy to figure out how to style ```directory_listing``` by looking at the source, but here are some gotchas:

- Every item listed is a ```<td>``` element in a table. Directories will have a class of ```dir``` and regular files will have a class of ```file```. 
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

### Contributing:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request