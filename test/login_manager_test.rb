require 'test_helper'

class LoginManagerTest < Test::Unit::TestCase
  
  def app
    Pamphlet::LoginManager.new(mock_app)
  end
  
  context "when an admin user exists" do
    setup do
      Pamphlet.settings[:admin_email] = "test4@example.com"
      Pamphlet.settings[:admin_password] = Pamphlet.salted_digest("test4password")
    end

    should "keep out teh fakers" do
      post "/login", :email => "fake_user@example.com", :password => "fakherrwah"
      assert_equal 401, last_response.status
      assert last_response.body.include?("Login failed")
    end
  
    should "authenticate the admin user" do
      post "/login", :email => "test4@example.com", :password => "test4password"
      assert_equal 302, last_response.status
    end
    
  end
end