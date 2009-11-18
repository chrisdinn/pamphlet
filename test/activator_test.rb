require 'test_helper'

class ActivatorTest < Test::Unit::TestCase

  def app
    Pamphlet::Activator
  end
  
  context "when the application is not activated" do
    setup do
      File.delete(Pamphlet::ACTIVATION_FILE) if File.exist?(Pamphlet::ACTIVATION_FILE)
      File.open(Pamphlet::SETTINGS_FILE, 'w') {|f| f.write({'activation_code_digest' => Digest::SHA256.hexdigest("abcd1234" + Pamphlet::ACTIVATION_SALT)}.to_yaml)}
    end
    
    should "display the activation form" do
      get Pamphlet::ACTIVATION_URL
      assert last_response.ok?
      assert last_response.body.include?("Enter activation code")
    end
    
    should "activate the application for users that have the activation code" do
      assert !File.exist?(Pamphlet::ACTIVATION_FILE)
      post Pamphlet::ACTIVATION_URL, :activation_code => "abcd1234"
      assert File.exist?(Pamphlet::ACTIVATION_FILE)
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