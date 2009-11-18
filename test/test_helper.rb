require 'rubygems'
require 'pamphlet'
require 'test/unit'
require 'shoulda'
require 'rack/test'

begin require 'redgreen'; rescue LoadError; end

Mail.defaults do
    delivery_method(:test)
end

class Test::Unit::TestCase
  include Rack::Test::Methods
  
  def mock_app
      @mock_app = lambda { |env| [200, { 'Content-Type' => 'text/html' }, 'Successful test'] }
  end
end
