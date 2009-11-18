require 'test_helper'

class ActivationCheckTest < Test::Unit::TestCase
  
  def app
    Pamphlet::ActivationCheck.new(mock_app)
  end
  
  context "when the application is not activated" do
    setup do
      File.delete(Pamphlet::ACTIVATION_FILE) if File.exist?(Pamphlet::ACTIVATION_FILE)
    end
    
    should "redirect all requests to the activation url" do
      ["/", "/login"].each do |route|
        get route
        follow_redirect!
      
        assert_match Regexp.new(Pamphlet::ACTIVATION_URL), last_request.url
      end
    end
    
    should "allow requests to the activation url" do
      get Pamphlet::ACTIVATION_URL
      assert last_response.ok?
    end
  end
  
  context "when the application has been activated" do
    setup do
      File.open(Pamphlet::ACTIVATION_FILE, 'w') {|f| f.write("abcd1234") } unless File.exist?(Pamphlet::ACTIVATION_FILE)
    end
    
    should "allow requests to continue along the stack" do
      get "/"
      status, headers, body = mock_app.call({})
      assert last_response.ok?
      assert_equal body, last_response.body
    end
    
  end

end