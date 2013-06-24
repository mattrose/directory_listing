### directory_listing: easy Apache-style directory listings for Sinatra.

### build from source:

```bash
gem build directory_listing.gemspec
sudo gem install ./directory_listing-x.x.x.gem
```

### usage:

Directory_listing will return HTML, so the following is a complete Sinatra app that will provide a directory listing of whatever path you navigate to:

```ruby
require 'directory_listing'

get '*' do |path|
	if File.exist?(File.join(settings.public_folder, path))
		"#{Directory_listing.list(
			:directory => path, 
			:sinatra_public => settings.public_folder,
			:should_list_invisibles => "no",
			:last_modified_format => "%Y-%m-%d %H:%M:%S",
			:dir_html_style => "bold",
			:regfile_html_style => "none",
			:filename_truncate_length => 40)}"
	else
		not_found
	end
end

not_found do
  'Try again.'
end
```

Any option key may be omitted except for :directory and :sinatra_public. Explanations of options are below.

### options:

```
directory # the directory to list
sinatra_public # sinatra's public folder - your public folder (and the default) is likely "settings.public_folder"
should_list_invisibles # should the directory listing include invisibles (dotfiles) - "yes" or "no"
last_modified_format # format for last modified date (http://www.ruby-doc.org/core-2.0/Time.html) - defaults to "%Y-%m-%d %H:%M:%S"
dir_html_style # html style for directories - "bold", "italic", "underline", or "none" - defaults to "bold"
regfile_html_style # html style for regular files - "bold", "italic", "underline", or "none" - defaults to "none"
filename_truncate_length # (integer) length to truncate file names to - defaults to 40

```