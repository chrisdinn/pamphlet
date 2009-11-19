require 'test_helper'

class ActivatorTest < Test::Unit::TestCase

  def app
    Pamphlet::Activator
  end
  
  context "when the application is not activated" do
    setup do
      Mail.deliveries.clear
      Pamphlet.deactivate
      Pamphlet.settings.set_activation_code("abcd1234")
    end
    
    should "display the activation form" do
      get Pamphlet::ACTIVATION_URL
      assert last_response.ok?
      assert last_response.body.include?("Enter activation code")
    end

    should "display the admin email form to users that have the activation code" do
      get Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234"
      assert last_response.ok?
      assert last_response.body.include?('Enter your email address')
    end
    
    should "send an activation email to the admin user containing an email activation code" do
      post Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234", :email => "test@pamphlet.com", :email_confirmation => "test@pamphlet.com"
      assert last_response.ok?
      assert_equal 1, Mail.deliveries.length
      assert_contains Mail.deliveries.first.to.addresses, "test@pamphlet.com"
      assert Mail.deliveries.first.body.to_s.include?( Pamphlet.salted_digest("test@pamphlet.com") )
      assert last_response.body.include?("email sent")
    end
    
    should "display admin password form for a user with a verified email address" do
      Pamphlet.settings.set_admin_email_activation_code("test2@pamphlet.com")
      get "#{Pamphlet::ACTIVATION_URL}/#{Pamphlet.settings[:email_activation_code_digest]}/edit"
      assert last_response.ok?
      assert last_response.body.include?("password")
    end
    
    should "create admin user and activate application" do
      assert !Pamphlet.activated?
      Pamphlet.settings.set_admin_email_activation_code("test3@pamphlet.com")
      put "#{Pamphlet::ACTIVATION_URL}/#{Pamphlet.settings[:email_activation_code_digest]}", :password => "test3password", :password_confirmation => "test3password"
      assert last_response.ok?
      assert Pamphlet.activated?
      assert_equal Pamphlet.settings[:admin_password], Pamphlet.salted_digest("test3password")
    end

  end
  
  context "when the application has been activated" do
    setup do
      Pamphlet.activate("abcd1234")
    end
    
    should "not display the activation form" do
      get Pamphlet::ACTIVATION_URL
      assert_equal 401, last_response.status
    end
    
    should "not allow the application to be reactivated" do
      post Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234"
      assert !last_response.ok?
    end
  end

end