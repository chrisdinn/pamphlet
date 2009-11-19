require 'test_helper'

class UserTest < Test::Unit::TestCase
  
  context "when an admin user exists" do
    setup do
      Pamphlet.settings[:admin_email] = "test4@example.com"
      Pamphlet.settings[:admin_password] = Pamphlet.salted_digest("test4password")
    end
    
    should "authenticate a provided email and password set and return itself" do
      assert Pamphlet::AdminUser.authenticate("test4@example.com", "test4password")
      assert !Pamphlet::AdminUser.authenticate("someharkez@triantogetin.com", "passw0rd")
    end
    
    should "provide a persistent token as a unique identifier" do
      assert_equal Pamphlet.salted_digest(Pamphlet.settings[:admin_email].split('@').first + Pamphlet.settings[:admin_password] ), Pamphlet::AdminUser.find.persistent_token
    end
    
    should "find admin user by persistent token" do
      a = Pamphlet::AdminUser.find
      assert a.persistent_token, Pamphlet.find_user(a.persistent_token).persistent_token
    end

  end
  
end