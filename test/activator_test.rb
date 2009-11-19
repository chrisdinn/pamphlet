require 'test_helper'

class ActivatorTest < Test::Unit::TestCase

  def app
    Pamphlet::Activator
  end
  
  context "when the application is not activated" do
    setup do
      Mail.deliveries.clear
      File.delete(Pamphlet::ACTIVATION_FILE) if File.exist?(Pamphlet::ACTIVATION_FILE)
      Pamphlet.settings['activation_code_digest'] = Digest::SHA256.hexdigest("abcd1234" + Pamphlet::ACTIVATION_SALT)
    end
    
    should "display the activation form" do
      get Pamphlet::ACTIVATION_URL
      assert last_response.ok?
      assert last_response.body.include?("Enter activation code")
    end
    
    #should "activate the application for users that have the activation code" do
    #  assert !File.exist?(Pamphlet::ACTIVATION_FILE)
    #  post Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234"
    #  assert File.exist?(Pamphlet::ACTIVATION_FILE)
    #end
    should "display the admin email form to users that have the activation code" do
      post Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234"
      assert last_response.ok?
      assert last_response.body.include?('Enter your email address')
    end
    
    should "send an activation email to the admin user containing an email activation code" do
      post Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234", :email => "test@pamphlet.com", :email_confirmation => "test@pamphlet.com"
      assert last_response.ok?
      assert_equal 1, Mail.deliveries.length
      assert_contains Mail.deliveries.first.to.addresses, "test@pamphlet.com"
      assert Mail.deliveries.first.body.to_s.include?(Digest::SHA256.hexdigest("test@pamphlet.com" + Pamphlet::ACTIVATION_SALT))
    end
        
  end
  
  context "when the application has been activated" do
    setup do
      File.open(Pamphlet::ACTIVATION_FILE, 'w') {|f| f.write("abcd1234") } unless File.exist?(Pamphlet::ACTIVATION_FILE)
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