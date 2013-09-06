### directory_listing: easy, CSS-styled, Apache-like directory listings for Sinatra.

### Description

```directory_listing``` is a [Sinatra](http://sinatrarb.com) plugin that generates Apache-like directory listings. It was designed to be:

1. Easy to use and configure
2. Style-able with CSS
3. Able to replicate all the features of Apache's directory listings including sorting

```directory_listing``` also includes a number of configuration options - see the [Options](#options) section below.

A short blog post / announcement exists [here](http://blog.catsanddogshavealltheluck.com/#Directory_Listings_in_Sinatra).

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

- ```stylesheet``` - a stylesheet that will be added to the <head> of the generated directory listing
- ```readme``` - an HTML string that will be appended at the footer of the generated directory listing
- ```should_list_invisibles``` - whether the directory listing should include invisibles (dotfiles) - true or false, defaults to false
- ```last_modified_format``` - [format](http://www.ruby-doc.org/core-2.0/Time.html) for last modified date - defaults to ```%Y-%m-%d %H:%M:%S```
- ```filename_truncate_length``` - (integer) length to truncate file names to - defaults to 40

### Styling

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

### Getting Help

The best way to report a bug or feature request is to [open an issue on GitHub](https://github.com/movesmyers/directory_listing/issues). 

Additionally, I'd love to hear your feedback about ```directory_listing``` through [Twitter](http://twitter.com/movesmyers) or [email](mailto:rick.myers@me.com).

### Contributing

1. Fork it
2. Create your feature branch (```git checkout -b my-new-feature```)
3. Commit your changes (```git commit -am 'Add some feature'```)
4. Push to the branch (```git push origin my-new-feature```)
5. Create new Pull Request

### License

```directory_listing``` is licensed under the DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE. See the LICENSE file for details.
