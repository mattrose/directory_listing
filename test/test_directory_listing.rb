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
end
