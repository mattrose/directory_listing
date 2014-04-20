ENV['RACK_ENV'] = 'test'

require_relative 'test_directory_listing_app'

require 'test/unit'
require 'rack/test'

class DirectoryListingTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
 
  ##
  # test that a request to the root directory is ok.

  def test_index
    get '/'
    assert last_response.ok?
  end

  ##
  # test trying to list a non-existent file or directory

  def test_not_found
    get '/does_not_exist'
    assert_equal 'Try again.', last_response.body
  end

  ##
  # test serving a file (not directory)

  def test_send_file
    get '/1234.txt'
    assert_equal '1234', last_response.body.chomp
  end

  ##
  # test defining a stylesheet

  def test_stylesheets
    get '/stylesheets'
    assert last_response.body.include?('/stylesheets/styles.css')
  end

  ##
  # test defining a readme

  def test_readme
    get '/readme'
    assert last_response.body.include?('this is my readme')
  end

  ##
  # test listing invisibles

  def test_should_list_invisibles
    get '/should_list_invisibles'
    assert (last_response.body.include?('/should_list_invisibles/.') and 
      last_response.body.include?('/should_list_invisibles/..'))
  end
  
  ##
  # test showing file extensions

  def test_should_show_file_exts
    get '/should_show_file_exts'
    assert !(last_response.body.include?('test.txt'))
  end

  ##
  # test sorting

  def files_array(body)
    files = Array.new
    body.each_line do |line|
      files << $& if /(\d)k.dat/.match(line)
    end
    files
  end

  def test_sorting_name_ascending
    get '/sorting?sortby=file&direction=ascending'
    files = files_array(last_response.body)
    assert_equal ["1k.dat", "2k.dat", "3k.dat"], files
  end

  def test_sorting_name_descending
    get '/sorting?sortby=file&direction=descending'
    files = files_array(last_response.body)
    assert_equal ["3k.dat", "2k.dat", "1k.dat"], files
  end
  
  def test_sorting_mtime_ascending
    get '/sorting?sortby=mtime&direction=ascending'
    files = files_array(last_response.body)
    assert_equal ["2k.dat", "3k.dat", "1k.dat"], files
  end

  def test_sorting_mtime_descending
    get '/sorting?sortby=mtime&direction=descending'
    files = files_array(last_response.body)
    assert_equal ["1k.dat", "3k.dat", "2k.dat"], files
  end

  def test_sorting_size_ascending
    get '/sorting?sortby=size&direction=ascending'
    files = files_array(last_response.body)
    assert_equal ["1k.dat", "2k.dat", "3k.dat"], files
  end

  def test_sorting_size_descending
    get '/sorting?sortby=size&direction=descending'
    files = files_array(last_response.body)
    assert_equal ["3k.dat", "2k.dat", "1k.dat"], files
  end

  ##
  # test navigation bar

  def test_navigation_bar
    get '/level1/level2/level3/level%204'
    assert last_response.body.include?('<a href=\'/level1/level2\'>level2</a>')
  end
end
